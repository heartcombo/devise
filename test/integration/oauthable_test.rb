require 'test_helper'

class OAuthableTest < ActionController::IntegrationTest
  FACEBOOK_INFO = {
    :username => 'usertest',
    :email => 'user@test.com'
  }

  ACCESS_TOKEN = {
    :access_token => "plataformatec"
  }

  stubs = Faraday::Adapter::Test::Stubs.new do |stub|
    stub.post('/oauth/access_token') { [200, {}, ACCESS_TOKEN.to_json] }
    stub.get('/me?access_token=plataformatec') { [200, {}, FACEBOOK_INFO.to_json] }
  end

  User.oauth_configs[:facebook].client.connection.build do |b|
    b.adapter :test, stubs
  end

  setup { Devise::Oauth.short_circuit_authorizers! }
  teardown { Devise::Oauth.unshort_circuit_authorizers! }

  test "omg" do
    assert_difference "User.count", 1 do
      get "/users/sign_up"
      click_link "Sign in with Facebook"
    end
  end
end