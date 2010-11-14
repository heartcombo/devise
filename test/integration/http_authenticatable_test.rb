require 'test_helper'

class HttpAuthenticationTest < ActionController::IntegrationTest

  test 'sign in should authenticate with http' do
    sign_in_as_new_user_with_http
    assert_response :success
    assert_match '<email>user@test.com</email>', response.body
    assert warden.authenticated?(:user)
  end

  test 'returns a custom response with www-authenticate header on failures' do
    sign_in_as_new_user_with_http("unknown")
    assert_equal 401, status
    assert_equal 'Basic realm="Application"', headers["WWW-Authenticate"]
  end

  test 'uses the request format as response content type' do
    sign_in_as_new_user_with_http("unknown")
    assert_equal 401, status
    assert_equal "application/xml; charset=utf-8", headers["Content-Type"]
    assert_match "<error>Invalid email or password.</error>", response.body
  end

  test 'returns a custom response with www-authenticate and chosen realm' do
    swap Devise, :http_authentication_realm => "MyApp" do
      sign_in_as_new_user_with_http("unknown")
      assert_equal 401, status
      assert_equal 'Basic realm="MyApp"', headers["WWW-Authenticate"]
    end
  end

  test 'sign in should authenticate with http even with specific authentication keys' do
    swap Devise, :authentication_keys => [:username] do
      sign_in_as_new_user_with_http("usertest")
      assert_response :success
      assert_match '<email>user@test.com</email>', response.body
      assert warden.authenticated?(:user)
    end
  end

  test 'test request with oauth2 header doesnt get mistaken for basic authentication' do
    swap Devise, :http_authenticatable => true do
      add_oauth2_header
      assert_equal 401, status
      assert_equal 'Basic realm="Application"', headers["WWW-Authenticate"]
    end
  end

  test 'sign in should authenticate with really long token' do
    token = "token_containing_so_many_characters_that_the_base64_encoding_will_wrap"
    user = create_user
    user.update_attribute :authentication_token, token
    get users_path(:format => :xml), {}, "HTTP_AUTHORIZATION" => "Basic #{ActiveSupport::Base64.encode64("#{token}:x")}"
    assert_response :success
    assert_match "<email>user@test.com</email>", response.body
    assert warden.authenticated?(:user)
  end
  
  private

    def sign_in_as_new_user_with_http(username="user@test.com", password="123456")
      user = create_user
      get users_path(:format => :xml), {}, "HTTP_AUTHORIZATION" => "Basic #{ActiveSupport::Base64.encode64("#{username}:#{password}")}"
      user
    end
    
    # Sign in with oauth2 token. This is just to test that it isn't misinterpreted as basic authentication
    def add_oauth2_header
      user = create_user
      get users_path(:format => :xml), {}, "HTTP_AUTHORIZATION" => "OAuth #{ActiveSupport::Base64.encode64("#{user.email}:123456")}"
    end

end