require 'test_helper'

class TokenAuthenticationTest < ActionController::IntegrationTest

  test 'authenticate with valid authentication token key and value through params' do
    swap Devise, :token_authentication_key => :secret_token do
      sign_in_as_new_user_with_token

      assert_response :success
      assert_current_url "/users?secret_token=#{VALID_AUTHENTICATION_TOKEN}"
      assert_contain 'Welcome'
      assert warden.authenticated?(:user)
    end
  end

  test 'authenticate with valid authentication token key but does not store if stateless' do
    swap Devise, :token_authentication_key => :secret_token, :stateless_token => true do
      sign_in_as_new_user_with_token
      assert warden.authenticated?(:user)

      get users_path
      assert_redirected_to new_user_session_path
      assert_not warden.authenticated?(:user)
    end
  end

  test 'authenticate with valid authentication token key and value through http' do
    swap Devise, :token_authentication_key => :secret_token do
      sign_in_as_new_user_with_token(:http_auth => true)

      assert_response :success
      assert_match '<email>user@test.com</email>', response.body
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
    store_translations :en, :devise => {:failure => {:invalid_token => 'LOL, that was not a single character correct.'}} do
      sign_in_as_new_user_with_token(:auth_token => '*** INVALID TOKEN ***')
      assert_equal new_user_session_path, @request.path

      assert_contain 'LOL, that was not a single character correct.'
      assert_contain 'Sign in'
      assert_not warden.authenticated?(:user)
    end
  end

  test 'authenticate with valid authentication token key and do not store if stateless and timeoutable are enabled' do
    swap Devise, :token_authentication_key => :secret_token, :stateless_token => true, :timeout_in => (0.1).second do
      user = sign_in_as_new_user_with_token
      assert warden.authenticated?(:user)

      # Expiring does not work because we are setting the session value when accessing it
      sleep 0.3

      get_users_path_as_existing_user(user)
      assert warden.authenticated?(:user)
    end
  end

  test 'should not be subject to injection' do
    swap Devise, :token_authentication_key => :secret_token do
      user1 = create_user_with_authentication_token()

      # Clean up user cache
      @user = nil

      user2 = create_user_with_authentication_token(:email => "another@test.com")
      user2.update_attribute(:authentication_token, "ANOTHERTOKEN")

      assert_not_equal user1, user2
      visit users_path(Devise.token_authentication_key.to_s + '[$ne]' => user1.authentication_token)
      assert_nil warden.user(:user) 
    end
  end

  private

    def sign_in_as_new_user_with_token(options = {})
      user = options.delete(:user) || create_user_with_authentication_token(options)

      options[:auth_token_key] ||= Devise.token_authentication_key
      options[:auth_token]     ||= user.authentication_token

      if options[:http_auth]
        header = "Basic #{ActiveSupport::Base64.encode64("#{VALID_AUTHENTICATION_TOKEN}:X")}"
        get users_path(:format => :xml), {}, "HTTP_AUTHORIZATION" => header
      else
        visit users_path(options[:auth_token_key].to_sym => options[:auth_token])
      end

      user
    end

    def create_user_with_authentication_token(options={})
      user = create_user(options)
      user.authentication_token = VALID_AUTHENTICATION_TOKEN
      user.save
      user
    end

    def get_users_path_as_existing_user(user)
      sign_in_as_new_user_with_token(:user => user)
    end

end