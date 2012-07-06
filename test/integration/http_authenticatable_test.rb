require 'test_helper'

class HttpAuthenticationTest < ActionController::IntegrationTest
  test 'handles unverified requests gets rid of caches but continues signed in' do
    swap UsersController, :allow_forgery_protection => true do
      create_user
      post exhibit_user_url(1), {}, "HTTP_AUTHORIZATION" => "Basic #{Base64.encode64("user@test.com:12345678")}"
      assert warden.authenticated?(:user)
      assert_equal "User is authenticated", response.body
    end
  end

  test 'sign in should authenticate with http' do
    sign_in_as_new_user_with_http
    assert_response 200
    assert_match '<email>user@test.com</email>', response.body
    assert warden.authenticated?(:user)

    get users_path(:format => :xml)
    assert_response 200
  end

  test 'sign in should authenticate with http but not emit a cookie if skipping session storage' do
    swap Devise, :skip_session_storage => [:http_auth] do
      sign_in_as_new_user_with_http
      assert_response 200
      assert_match '<email>user@test.com</email>', response.body
      assert warden.authenticated?(:user)

      get users_path(:format => :xml)
      assert_response 401
    end
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
    get users_path(:format => :xml), {}, "HTTP_AUTHORIZATION" => "Basic #{Base64.encode64("#{token}:x")}"
    assert_response :success
    assert_match "<email>user@test.com</email>", response.body
    assert warden.authenticated?(:user)
  end

  private

    def sign_in_as_new_user_with_http(username="user@test.com", password="12345678")
      user = create_user
      get users_path(:format => :xml), {}, "HTTP_AUTHORIZATION" => "Basic #{Base64.encode64("#{username}:#{password}")}"
      user
    end

    # Sign in with oauth2 token. This is just to test that it isn't misinterpreted as basic authentication
    def add_oauth2_header
      user = create_user
      get users_path(:format => :xml), {}, "HTTP_AUTHORIZATION" => "OAuth #{Base64.encode64("#{user.email}:12345678")}"
    end

end
