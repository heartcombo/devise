require 'test_helper'

class TokenAuthenticationTest < ActionController::IntegrationTest

  test 'sign in should authenticate with valid authentication token and proper authentication token key' do
    swap Devise, :token_authentication_key => :secret_token do
      sign_in_as_new_user_with_token(:auth_token_key => :secret_token)

      assert_response :success
      assert_template 'users/index'
      assert_contain 'Welcome'
      assert warden.authenticated?(:user)
    end
  end

  test 'signing in with valid authentication token - but improper authentication token key - return to sign in form with error message' do
    swap Devise, :token_authentication_key => :donald_duck_token do
      sign_in_as_new_user_with_token(:auth_token_key => :secret_token)
      assert_current_path new_user_session_path(:unauthenticated => true)

      assert_contain 'You need to sign in or sign up before continuing'
      assert_contain 'Sign in'
      assert_not warden.authenticated?(:user)
    end
  end

  test 'signing in with invalid authentication token should return to sign in form with error message' do
    store_translations :en, :devise => {:sessions => {:invalid_token => 'LOL, that was not a single character correct.'}} do
      sign_in_as_new_user_with_token(:auth_token => '*** INVALID TOKEN ***')
      assert_current_path new_user_session_path(:invalid_token => true)

      assert_response :success
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

      visit users_path(options[:auth_token_key].to_sym => options[:auth_token])
      user
    end

end