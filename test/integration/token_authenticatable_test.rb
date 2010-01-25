require 'test/test_helper'

class TokenAuthenticationTest < ActionController::IntegrationTest

  test 'sign in user should authenticate with valid authentication token and proper authentication token key' do
    swap Devise, :authentication_token_param_key => :secret_token do
      sign_in_as_new_user_with_token(:auth_token_key => :secret_token, :auth_token => VALID_AUTHENTICATION_TOKEN)

      assert_response :success
      assert_template 'users/index'
      assert_contain 'Welcome'
      assert warden.authenticated?(:user)
    end
  end

  test 'user signing in with valid authentication token - but improper authentication token key - return to sign in form with error message' do
    # FIXME: For some reason I18n value is not respected. Always render defalt one. =S
    # store_translations :en, :devise => {:sessions => {:unauthenticated => 'Ouch!'}} do
      # assert 'Ouch!', I18n.t('devise.sessions.unauthenticated') # for paranoia

      swap Devise, :authentication_token_param_key => :donald_duck_token do
        sign_in_as_new_user_with_token(:auth_token_key => :secret_token, :auth_token => VALID_AUTHENTICATION_TOKEN)

        assert_redirected_to new_user_session_path(:unauthenticated => true)
        follow_redirect!

        # assert_contain 'Ouch!'
        assert_contain 'Sign in'
        assert_not warden.authenticated?(:user)
      end
    # end
  end

  test 'user signing in with invalid authentication token should return to sign in form with error message' do
    store_translations :en, :devise => {:sessions => {:invalid_token => 'LOL, that was not a single character correct.'}} do
      sign_in_as_new_user_with_token(:auth_token => '*** INVALID TOKEN ***')

      assert_redirected_to new_user_session_path(:invalid_token => true)
      follow_redirect!
      assert_equal users_path(Devise.authentication_token_param_key => '*** INVALID TOKEN ***'), session[:"user.return_to"]

      assert_response :success
      assert_contain 'LOL, that was not a single character correct.'
      assert_contain 'Sign in'
      assert_not warden.authenticated?(:user)
    end
  end

  private

    def sign_in_as_new_user_with_token(options = {}, &block)
      options[:auth_token_key] ||= Devise.authentication_token_param_key
      user = create_user(options)
      user.authentication_token = VALID_AUTHENTICATION_TOKEN
      user.save
      visit users_path(options[:auth_token_key].to_sym => (options[:auth_token] || VALID_AUTHENTICATION_TOKEN))
      yield if block_given?
      user
    end

end