require 'test/test_helper'

class AuthenticationTest < ActionController::IntegrationTest

  test 'home should be accessible without signed in admins' do
    visit '/'
    assert_response :success
    assert_template 'home/index'
  end

  test 'sign in as user should not authenticate admin scope' do
    sign_in_as_user

    assert warden.authenticated?(:user)
    assert_not warden.authenticated?(:admin)
  end

  test 'sign in as admin should not authenticate user scope' do
    sign_in_as_admin

    assert warden.authenticated?(:admin)
    assert_not warden.authenticated?(:user)
  end

  test 'sign in as both user and admin at same time' do
    sign_in_as_user
    sign_in_as_admin

    assert warden.authenticated?(:user)
    assert warden.authenticated?(:admin)
  end

  test 'sign out as user should not touch admin authentication' do
    sign_in_as_user
    sign_in_as_admin

    delete user_session_path
    assert_not warden.authenticated?(:user)
    assert warden.authenticated?(:admin)
  end

  test 'sign out as admin should not touch user authentication' do
    sign_in_as_user
    sign_in_as_admin

    delete admin_session_path
    assert_not warden.authenticated?(:admin)
    assert warden.authenticated?(:user)
  end
end
