require 'test_helper'

class SessionTimeoutTest < ActionController::IntegrationTest

  def last_request_at
    @controller.user_session['last_request_at']
  end

  test 'set last request at in user session after each request' do
    sign_in_as_user
    old_last_request = last_request_at
    assert_not_nil last_request_at

    get users_path
    assert_not_nil last_request_at
    assert_not_equal old_last_request, last_request_at
  end

  test 'not time out user session before default limit time' do
    sign_in_as_user
    assert_response :success
    assert warden.authenticated?(:user)

    get users_path
    assert_response :success
    assert warden.authenticated?(:user)
  end

  test 'time out user session after default limit time' do
    user = sign_in_as_user
    get expire_user_path(user)
    assert_not_nil last_request_at

    get users_path
    assert_redirected_to new_user_session_path
    assert_not warden.authenticated?(:user)
  end

  test 'time out is not triggered on sign out' do
    user = sign_in_as_user
    get expire_user_path(user)

    get destroy_user_session_path
    assert_response :redirect
    assert_redirected_to root_path

    follow_redirect!
    assert_contain 'Signed out successfully'
  end

  test 'user configured timeout limit' do
    swap Devise, :timeout_in => 8.minutes do
      user = sign_in_as_user

      get users_path
      assert_not_nil last_request_at
      assert_response :success
      assert warden.authenticated?(:user)

      get expire_user_path(user)
      get users_path
      assert_redirected_to new_user_session_path
      assert_not warden.authenticated?(:user)
    end
  end

  test 'error message with i18n' do
    store_translations :en, :devise => {
      :failure => { :user => { :timeout => 'Session expired!' } }
    } do
      user = sign_in_as_user

      get expire_user_path(user)
      get users_path
      follow_redirect!
      assert_contain 'Session expired!'
    end
  end
  
  test 'time out not triggered if remembered' do
    user = sign_in_as_user :remember_me => true
    get expire_user_path(user)
    assert_not_nil last_request_at
    
    get users_path
    assert_response :success
    assert warden.authenticated?(:user)
  end
end
