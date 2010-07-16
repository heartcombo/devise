require 'test_helper'

class OAuthableTest < ActionController::IntegrationTest
  FACEBOOK_INFO = {
    :username => 'usertest',
    :email => 'user@test.com'
  }

  ACCESS_TOKEN = {
    :access_token => "plataformatec"
  }

  setup do
    Devise::Oauth.short_circuit_authorizers!
  end

  teardown do
    Devise::Oauth.unshort_circuit_authorizers!
    Devise::Oauth.reset_stubs!
  end

  def stub_facebook!(times=1)
    data = (times == 1) ? FACEBOOK_INFO : FACEBOOK_INFO.except(:email)

    Devise::Oauth.stub!(:facebook) do |b|
      b.post('/oauth/access_token') { [200, {}, ACCESS_TOKEN.to_json] }
      times.times {
        b.get('/me?access_token=plataformatec') { [200, {}, data.to_json] }
      }
    end
  end

  test "basic setup with persisted user" do
    stub_facebook!

    assert_difference "User.count", 1 do
      visit "/users/sign_in"
      click_link "Sign in with Facebook"
    end

    assert_current_url "/"
    assert_contain "Successfully authorized from Facebook account."

    assert warden.authenticated?(:user)
    assert_not warden.authenticated?(:admin)
  end

  test "basic setup with not persisted user and follow up" do
    stub_facebook!(2)

    assert_no_difference "User.count" do
      visit "/users/sign_in"
      click_link "Sign in with Facebook"
    end

    assert_contain "1 error prohibited this user from being saved"
    assert_contain "Email can't be blank"

    assert_not warden.authenticated?(:user)
    assert_not warden.authenticated?(:admin)

    fill_in "Email", :with => "user.form@test.com"
    click_button "Sign up"

    assert_current_url "/"
    assert_contain "You have signed up successfully."
    assert_contain "Hello User user.form@test.com"

    assert warden.authenticated?(:user)
    assert_not warden.authenticated?(:admin)
  end
end