require 'test/test_helper'

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
    assert_redirected_to new_user_session_path(:timeout => true)
    assert_not warden.authenticated?(:user)
  end

  test 'user configured timeout limit' do
    swap Devise, :timeout => 8.minutes do
      user = sign_in_as_user

      get users_path
      assert_not_nil last_request_at
      assert_response :success
      assert warden.authenticated?(:user)

      get expire_user_path(user)
      get users_path
      assert_redirected_to new_user_session_path(:timeout => true)
      assert_not warden.authenticated?(:user)
    end
  end

  test 'error message with i18n' do
    store_translations :en, :devise => {
      :sessions => { :user => { :timeout => 'Session expired!' } }
    } do
      user = sign_in_as_user

      get expire_user_path(user)
      get users_path
      follow_redirect!
      assert_contain 'Session expired!'
    end
  end

end
