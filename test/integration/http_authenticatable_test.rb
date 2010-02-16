require 'test/test_helper'

class HttpAuthenticationTest < ActionController::IntegrationTest

  test 'sign in should authenticate with http' do
    sign_in_as_new_user_with_http
    assert_response :success
    assert_template 'users/index'
    assert_contain 'Welcome'
    assert warden.authenticated?(:user)
  end

  test 'returns a custom response with www-authenticate header on failures' do
    sign_in_as_new_user_with_http("unknown")
    assert_equal 401, status
    assert_equal 'Basic realm="Application"', headers["WWW-Authenticate"]
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
      sign_in_as_new_user_with_http "usertest"
      assert_response :success
      assert_template 'users/index'
      assert_contain 'Welcome'
      assert warden.authenticated?(:user)
    end
  end

  private

    def sign_in_as_new_user_with_http(username="user@test.com", password="123456")
      user = create_user
      get users_path, {}, "HTTP_AUTHORIZATION" => "Basic #{ActiveSupport::Base64.encode64("#{username}:#{password}")}"
      user
    end
end