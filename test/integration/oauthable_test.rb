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

    Devise::Oauth.stub!(:facebook) do |b|
      b.post('/oauth/access_token') { [200, {}, ACCESS_TOKEN.to_json] }
      b.get('/me?access_token=plataformatec') { [200, {}, FACEBOOK_INFO.to_json] }
    end
  end

  teardown do
    Devise::Oauth.unshort_circuit_authorizers!
    Devise::Oauth.reset_stubs!
  end

  test "omg" do
    assert_difference "User.count", 1 do
      get "/users/sign_in"
      click_link "Sign in with Facebook"
    end
  end
end