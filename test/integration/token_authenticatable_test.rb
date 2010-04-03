require 'test_helper'

class TokenAuthenticationTest < ActionController::IntegrationTest

  test 'authenticate with valid authentication token key and value through params' do
    swap Devise, :token_authentication_key => :secret_token do
      sign_in_as_new_user_with_token

      assert_response :success
      assert_template 'users/index'
      assert_contain 'Welcome'
      assert warden.authenticated?(:user)
    end
  end

  test 'authenticate with valid authentication token key and value through http' do
    swap Devise, :token_authentication_key => :secret_token do
      sign_in_as_new_user_with_token(:http_auth => true)

      assert_response :success
      assert_template 'users/index'
      assert_contain 'Welcome'
      assert warden.authenticated?(:user)
    end
  end

  test 'does authenticate with valid authentication token key and value through params if not configured' do
    swap Devise, :token_authentication_key => :secret_token, :params_authenticatable => [:database] do
      sign_in_as_new_user_with_token

      assert_contain 'You need to sign in or sign up before continuing'
      assert_contain 'Sign in'
      assert_not warden.authenticated?(:user)
    end
  end

  test 'does authenticate with valid authentication token key and value through http if not configured' do
    swap Devise, :token_authentication_key => :secret_token, :http_authenticatable => [:database] do
      sign_in_as_new_user_with_token(:http_auth => true)

      assert_response 401
      assert_contain 'Invalid email or password.'
      assert_not warden.authenticated?(:user)
    end
  end

  test 'does not authenticate with improper authentication token key' do
    swap Devise, :token_authentication_key => :donald_duck_token do
      sign_in_as_new_user_with_token(:auth_token_key => :secret_token)
      assert_equal new_user_session_path, @request.path

      assert_contain 'You need to sign in or sign up before continuing'
      assert_contain 'Sign in'
      assert_not warden.authenticated?(:user)
    end
  end

  test 'does not authenticate with improper authentication token value' do
    store_translations :en, :devise => {:sessions => {:invalid_token => 'LOL, that was not a single character correct.'}} do
      sign_in_as_new_user_with_token(:auth_token => '*** INVALID TOKEN ***')
      assert_equal new_user_session_path, @request.path

      assert_contain 'LOL, that was not a single character correct.'
      assert_contain 'Sign in'
      assert_not warden.authenticated?(:user)
    end
  end

  private

    def sign_in_as_new_user_with_token(options = {})
      options[:auth_token_key] ||= Devise.token_authentication_key
      options[:auth_token]     ||= VALID_AUTHENTICATION_TOKEN

      user = create_user(options)
      user.authentication_token = VALID_AUTHENTICATION_TOKEN
      user.save

      if options[:http_auth]
        header = "Basic #{ActiveSupport::Base64.encode64("#{VALID_AUTHENTICATION_TOKEN}:X")}"
        get users_path, {}, "HTTP_AUTHORIZATION" => header
      else
        visit users_path(options[:auth_token_key].to_sym => options[:auth_token])
      end

      user
    end

end