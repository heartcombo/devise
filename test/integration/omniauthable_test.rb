require 'test_helper'

class OmniauthableIntegrationTest < ActionController::IntegrationTest
  FACEBOOK_INFO = {
    :id => '12345',
    :link => 'http://facebook.com/josevalim',
    :email => 'user@example.com',
    :first_name => 'Jose',
    :last_name => 'Valim',
    :website => 'http://blog.plataformatec.com.br'
  }

  ACCESS_TOKEN = {
    :access_token => "plataformatec"
  }

  setup do
    stub_facebook!
    Devise::OmniAuth.short_circuit_authorizers!
  end

  teardown do
    Devise::OmniAuth.unshort_circuit_authorizers!
    Devise::OmniAuth.reset_stubs!
  end

  def stub_facebook!
    Devise::OmniAuth.stub!(:facebook) do |b|
      b.post('/oauth/access_token') { [200, {}, ACCESS_TOKEN.to_json] }
      b.get('/me?access_token=plataformatec') { [200, {}, FACEBOOK_INFO.to_json] }
    end
  end

  test "can access omniauth.auth in the env hash" do
    visit "/users/sign_in"
    click_link "Sign in with Facebook"

    json = ActiveSupport::JSON.decode(response.body)

    assert_equal "12345",         json["uid"]
    assert_equal "facebook",      json["provider"]
    assert_equal "josevalim",     json["user_info"]["nickname"]
    assert_equal FACEBOOK_INFO,   json["extra"]["user_hash"].symbolize_keys
    assert_equal "plataformatec", json["credentials"]["token"]
  end

  test "cleans up session on sign up" do  
    assert_no_difference "User.count" do
      visit "/users/sign_in"
      click_link "Sign in with Facebook"
    end

    assert session["devise.facebook_data"]

    assert_difference "User.count" do
      visit "/users/sign_up"
      fill_in "Password", :with => "123456"
      fill_in "Password confirmation", :with => "123456"
      click_button "Sign up"
    end

    assert_current_url "/"
    assert_contain "You have signed up successfully."
    assert_contain "Hello User user@example.com"
    assert_not session["devise.facebook_data"]
  end

  test "cleans up session on cancel" do  
    assert_no_difference "User.count" do
      visit "/users/sign_in"
      click_link "Sign in with Facebook"
    end

    assert session["devise.facebook_data"]
    visit "/users/cancel"
    assert !session["devise.facebook_data"]
  end

  test "cleans up session on sign in" do  
    assert_no_difference "User.count" do
      visit "/users/sign_in"
      click_link "Sign in with Facebook"
    end

    assert session["devise.facebook_data"]
    user = sign_in_as_user
    assert !session["devise.facebook_data"]
  end

  test "handles callback error parameter according to the specification" do
    visit "/users/auth/facebook/callback?error=access_denied"
    assert_current_url "/users/sign_in"
    assert_contain 'Could not authorize you from Facebook because "Access denied".'
  end

  test "handles other exceptions from omniauth" do
    Devise::OmniAuth.stub!(:facebook) do |b|
      b.post('/oauth/access_token') { [401, {}, {}.to_json] }
    end

    visit "/users/sign_in"
    click_link "Sign in with facebook"

    assert_current_url "/users/sign_in"
    assert_contain 'Could not authorize you from Facebook because "Invalid credentials".'
  end
end