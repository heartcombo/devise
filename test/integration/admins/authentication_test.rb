require 'test/test_helper'

class AdminsAuthenticationTest < ActionController::IntegrationTest

  test 'not signed in as admin should not be able to access admins actions' do
    get admins_path

    assert_redirected_to new_admin_session_path(:message => :unauthenticated)
    assert_not warden.authenticated?(:admin)
  end

  test 'signed in as user should not be able to access admins actions' do
    sign_in_as_user
    assert warden.authenticated?(:user)
    assert_not warden.authenticated?(:admin)

    get admins_path
    assert_redirected_to new_admin_session_path(:message => :unauthenticated)
  end

  test 'signed in as admin should be able to access admin actions successfully' do
    sign_in_as_admin
    assert warden.authenticated?(:admin)
    assert_not warden.authenticated?(:user)

    get admins_path

    assert_response :success
    assert_template 'admins/index'
    assert_contain 'Welcome Admin'
  end

  test 'admin signing in with invalid email should return to sign in form with error message' do
    sign_in_as_admin do
      fill_in 'email', :with => 'wrongemail@test.com'
    end

    assert_response :success
    assert_template 'sessions/new'
    assert_contain 'Invalid email or password'
    assert_not warden.authenticated?(:admin)
  end

  test 'admin signing in with invalid pasword should return to sign in form with error message' do
    sign_in_as_admin do
      fill_in 'password', :with => 'abcdef'
    end

    assert_response :success
    assert_template 'sessions/new'
    assert_contain 'Invalid email or password'
    assert_not warden.authenticated?(:admin)
  end

  # TODO This test should not pass
  test 'not confirmed admin should not be able to login' do
    sign_in_as_admin(:confirm => false)

    assert_contain 'Invalid email or password'
    assert_not warden.authenticated?(:admin)
  end

  test 'already confirmed admin should be able to sign in successfully' do
    sign_in_as_admin

    assert_response :success
    assert_template 'home/index'
    assert_contain 'Signed in successfully'
    assert_not_contain 'Sign In'
    assert warden.authenticated?(:admin)
    assert_not warden.authenticated?(:user)
  end

  test 'authenticated admin should be able to sign out' do
    sign_in_as_admin
    assert warden.authenticated?(:admin)

    delete admin_session_path
    assert_response :redirect
    assert_redirected_to root_path
    assert_not warden.authenticated?(:admin)
  end
end
