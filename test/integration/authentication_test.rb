require 'test/test_helper'

class AuthenticationTest < ActionController::IntegrationTest

  test 'not authenticated user should load up sign in form' do
    visit '/'
    assert_response :success
    assert_template 'sessions/new'
  end

  test 'signing in with invalid email should return to sign in form with error message' do
    sign_in do
      fill_in 'email', :with => 'wrongemail@test.com'
    end

    assert_response :success
    assert_template 'sessions/new'
    assert_contain 'Invalid email or password'
    assert !warden.authenticated?
  end

  test 'signing in with invalid pasword should return to sign in form with error message' do
    sign_in do
      fill_in 'password', :with => 'abcdef'
    end

    assert_response :success
    assert_template 'sessions/new'
    assert_contain 'Invalid email or password'
    assert !warden.authenticated?
  end

  test 'not confirmed user should not be able to login' do
    sign_in(:confirm => false)

    assert_contain 'Invalid email or password'
    assert !warden.authenticated?
  end

  test 'already confirmed user should be able to sign in successfully' do
    sign_in

    assert_response :success
    assert_template 'home/index'
    assert_contain 'Signed in successfully'
    assert_not_contain 'Sign In'
    assert warden.authenticated?
  end

  test 'not authenticated user should not be able to sign out' do
    delete 'users/session'

    assert_response :success
    assert_template 'sessions/new'
    assert !warden.authenticated?
  end

  test 'authenticated user should be able to sign out' do
    sign_in
    assert warden.authenticated?

    delete 'users/session'
    assert_response :redirect
    assert_redirected_to new_user_session_path
    assert !warden.authenticated?
  end
end
