require 'test_helper'

class OauthableTest < ActiveSupport::TestCase
  teardown { Devise::Oauth.reset_stubs! }
    
  test "oauth_configs returns all configurations relative to that model" do
    swap User, :oauth_providers => [:github] do
      assert_equal User.oauth_configs, Devise.oauth_configs.slice(:github)
    end
  end

  test "oauth_access_token returns the token object for the given provider" do
    Devise::Oauth.stub!(:facebook) do |b|
      b.get('/me?access_token=plataformatec') { [200, {}, {}.to_json] }
    end

    access_token = User.oauth_access_token(:facebook, "plataformatec")
    assert_kind_of OAuth2::AccessToken, access_token
    assert_equal "{}", access_token.get("/me")
  end
end