require 'test/test_helper'

class UsersAuthenticationTest < ActionController::IntegrationTest

  test 'home should be accessible without signed in users' do
    visit '/'
    assert_response :success
    assert_template 'home/index'
  end

  test 'not signed in as user should not be able to access users actions' do
    get users_path

    assert_response :redirect
    assert_redirected_to new_user_session_path
    assert_not warden.authenticated?(:user)
  end

  test 'signed in as admin should not be able to access users actions' do
    sign_in_as_admin
    assert warden.authenticated?(:admin)
    assert_not warden.authenticated?(:user)

    get users_path

    assert_response :redirect
    assert_redirected_to new_user_session_path

  end
  test 'signed in as user should be able to access users actions successfully' do
    sign_in_as_user
    assert warden.authenticated?(:user)
    assert_not warden.authenticated?(:admin)

    get users_path

    assert_response :success
    assert_template 'users/index'
    assert_contain 'Welcome User'
  end

  test 'user signing in with invalid email should return to sign in form with error message' do
    sign_in_as_user do
      fill_in 'email', :with => 'wrongemail@test.com'
    end

    assert_response :success
    assert_template 'sessions/new'
    assert_contain 'Invalid email or password'
    assert_not warden.authenticated?(:user)
  end

  test 'user signing in with invalid pasword should return to sign in form with error message' do
    sign_in_as_user do
      fill_in 'password', :with => 'abcdef'
    end

    assert_response :success
    assert_template 'sessions/new'
    assert_contain 'Invalid email or password'
    assert_not warden.authenticated?(:user)
  end

  test 'not confirmed user should not be able to login' do
    sign_in_as_user(:confirm => false)

    assert_contain 'Invalid email or password'
    assert_not warden.authenticated?(:user)
  end

  test 'already confirmed user should be able to sign in successfully' do
    sign_in_as_user

    assert_response :success
    assert_template 'home/index'
    assert_contain 'Signed in successfully'
    assert_not_contain 'Sign In'
    assert warden.authenticated?(:user)
    assert_not warden.authenticated?(:admin)
  end

  test 'not authenticated user should not be able to sign out' do
    delete user_session_path

    assert_response :redirect
    assert_redirected_to new_user_session_path
    assert_not warden.authenticated?(:user)
  end

  test 'authenticated user should be able to sign out' do
    sign_in_as_user
    assert warden.authenticated?(:user)

    delete user_session_path
    assert_response :redirect
    assert_redirected_to new_user_session_path
    assert_not warden.authenticated?(:user)
  end
end
