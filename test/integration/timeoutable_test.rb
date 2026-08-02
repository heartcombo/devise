# frozen_string_literal: true

require 'test_helper'

class SessionTimeoutTest < Devise::IntegrationTest

  def last_request_at
    @controller.user_session['last_request_at']
  end

  test 'set last request at in user session after each request' do
    sign_in_as_user
    assert_not_nil last_request_at

    @controller.user_session.delete('last_request_at')
    get users_path
    assert_not_nil last_request_at
  end

  test 'set last request at in user session after each request is skipped if tracking is disabled' do
    sign_in_as_user
    old_last_request = last_request_at
    assert_not_nil last_request_at

    get users_path, headers: { 'devise.skip_trackable' => true }
    assert_equal old_last_request, last_request_at
  end

  test 'does not set last request at in user session after each request if timeoutable is disabled' do
    sign_in_as_user
    old_last_request = last_request_at
    assert_not_nil last_request_at

    new_time = 2.seconds.from_now
    Time.stubs(:now).returns(new_time)

    get users_path, headers: { 'devise.skip_timeoutable' => true }
    assert_equal old_last_request, last_request_at
  end

  test 'does not time out user session before default limit time' do
    sign_in_as_user
    assert_response :success
    assert warden.authenticated?(:user)

    get users_path
    assert_response :success
    assert warden.authenticated?(:user)
  end

  test 'time out user session after default limit time when sign_out_all_scopes is false' do
    swap Devise, sign_out_all_scopes: false do
      sign_in_as_admin

      user = sign_in_as_user
      get expire_user_path(user)
      assert_not_nil last_request_at

      get users_path
      assert_redirected_to users_path
      assert_not warden.authenticated?(:user)
      assert warden.authenticated?(:admin)
    end
  end

  test 'time out all sessions after default limit time when sign_out_all_scopes is true' do
    swap Devise, sign_out_all_scopes: true do
      sign_in_as_admin

      user = sign_in_as_user
      get expire_user_path(user)
      assert_not_nil last_request_at

      get root_path
      assert_not warden.authenticated?(:user)
      assert_not warden.authenticated?(:admin)
    end
  end

  test 'time out user session after default limit time and redirect to latest get request' do
    user = sign_in_as_user
    visit edit_form_user_path(user)

    click_button 'Update'
    sign_in_as_user

    assert_equal edit_form_user_url(user), current_url
  end

  test 'time out on non-GET request does not redirect to an external host supplied via the referer' do
    user = sign_in_as_user
    get expire_user_path(user)

    put update_form_user_path(user), headers: { 'HTTP_REFERER' => 'http://evil.example/phishing' }

    assert_response :redirect
    assert_redirected_to '/phishing'
  end

  test 'time out on non-GET request with an opaque referer falls back to the sign in page' do
    user = sign_in_as_user
    get expire_user_path(user)

    put update_form_user_path(user), headers: { 'HTTP_REFERER' => 'javascript:alert(1)' }

    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test 'time out is not triggered on sign out' do
    user = sign_in_as_user
    get expire_user_path(user)

    delete destroy_user_session_path

    assert_response :redirect
    assert_redirected_to root_path
    follow_redirect!
    assert_contain 'Signed out successfully'
  end

  test 'expired session is not extended by sign in page' do
    user = sign_in_as_user
    get expire_user_path(user)
    assert warden.authenticated?(:user)

    get "/users/sign_in"
    assert_redirected_to "/users/sign_in"
    follow_redirect!

    assert_response :success
    assert_contain 'Log in'
    assert_not warden.authenticated?(:user)
  end

  test 'time out is not triggered on sign in' do
    user = sign_in_as_user
    get expire_user_path(user)

    post "/users/sign_in", params: { email: user.email, password: "123456" }

    assert_response :redirect
    follow_redirect!
    assert_contain 'You are signed in'
  end

  test 'user configured timeout limit' do
    swap Devise, timeout_in: 8.minutes do
      user = sign_in_as_user

      get users_path
      assert_not_nil last_request_at
      assert_response :success
      assert warden.authenticated?(:user)

      get expire_user_path(user)
      get users_path
      assert_redirected_to users_path
      assert_not warden.authenticated?(:user)
    end
  end

  test 'error message with i18n' do
    store_translations :en, devise: {
      failure: { user: { timeout: 'Session expired!' } }
    } do
      user = sign_in_as_user

      get expire_user_path(user)
      get root_path
      follow_redirect!
      assert_contain 'Session expired!'
    end
  end

  test 'error message with i18n with double redirect' do
    store_translations :en, devise: {
      failure: { user: { timeout: 'Session expired!' } }
    } do
      user = sign_in_as_user

      get expire_user_path(user)
      get users_path
      follow_redirect!
      follow_redirect!
      assert_contain 'Session expired!'
    end
  end

  test 'error message redirect respects i18n locale set' do
    user = sign_in_as_user

    get expire_user_path(user)
    get root_path(locale: "pt-BR")
    follow_redirect!

    assert_contain 'Sua sessão expirou. Por favor faça o login novamente para continuar.'
    assert_not warden.authenticated?(:user)
  end

  test 'time out not triggered if remembered' do
    user = sign_in_as_user remember_me: true
    get expire_user_path(user)
    assert_not_nil last_request_at

    get users_path
    assert_response :success
    assert warden.authenticated?(:user)
  end

  test 'does not update last_request_at within the last_request_at_update_interval' do
    swap Devise, last_request_at_update_interval: 5.minutes do
      sign_in_as_user
      first_request_at = last_request_at
      assert_not_nil first_request_at

      get users_path
      assert_equal first_request_at, last_request_at
    end
  end

  test 'updates last_request_at after the last_request_at_update_interval has elapsed' do
    swap Devise, last_request_at_update_interval: 5.minutes do
      sign_in_as_user
      first_request_at = last_request_at
      assert_not_nil first_request_at

      new_time = 6.minutes.from_now
      Time.stubs(:now).returns(new_time)

      get users_path
      assert_not_equal first_request_at, last_request_at
    end
  end

  test 'last_request_at_update_interval defaults to nil and writes on every request' do
    assert_nil Devise.last_request_at_update_interval

    sign_in_as_user
    first_request_at = last_request_at

    new_time = 10.seconds.from_now
    Time.stubs(:now).returns(new_time)

    get users_path
    assert_not_equal first_request_at, last_request_at
  end

  test 'does not crash when the last_request_at is a String' do
    user = sign_in_as_user

    assert_nothing_raised do
      get edit_form_user_path(user, last_request_at: Time.now.utc.to_s)
      get users_path
    end
  end
end
