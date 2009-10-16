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

    get destroy_user_session_path
    assert_not warden.authenticated?(:user)
    assert warden.authenticated?(:admin)
  end

  test 'sign out as admin should not touch user authentication' do
    sign_in_as_user
    sign_in_as_admin

    get destroy_admin_session_path
    assert_not warden.authenticated?(:admin)
    assert warden.authenticated?(:user)
  end

  test 'not signed in as admin should not be able to access admins actions' do
    get admins_path

    assert_redirected_to new_admin_session_path(:unauthenticated => true)
    assert_not warden.authenticated?(:admin)
  end

  test 'signed in as user should not be able to access admins actions' do
    sign_in_as_user
    assert warden.authenticated?(:user)
    assert_not warden.authenticated?(:admin)

    get admins_path
    assert_redirected_to new_admin_session_path(:unauthenticated => true)
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

  test 'error message is configurable by resource name' do
    begin
      I18n.backend.store_translations(:en, :devise => { :sessions =>
        { :admin => { :unauthenticated => "Invalid credentials" } } })

      sign_in_as_admin do
        fill_in 'password', :with => 'abcdef'
      end

      assert_contain 'Invalid credentials'
    ensure
      I18n.reload!
    end
  end

  test 'authenticated admin should not be able to sign as admin again' do
    sign_in_as_admin
    get new_admin_session_path

    assert_response :redirect
    assert_redirected_to root_path
    assert warden.authenticated?(:admin)
  end

  test 'authenticated admin should be able to sign out' do
    sign_in_as_admin
    assert warden.authenticated?(:admin)

    get destroy_admin_session_path
    assert_response :redirect
    assert_redirected_to root_path

    get root_path
    assert_contain 'Signed out successfully'
    assert_not warden.authenticated?(:admin)
  end

  test 'not authenticated admin does not set error message on sign out' do
    get destroy_admin_session_path
    assert_response :redirect
    assert_redirected_to root_path

    get root_path
    assert_not_contain 'Signed out successfully'
  end

  test 'redirect with warden show error message' do
    get admins_path

    warden_path = new_admin_session_path(:unauthenticated => true)
    assert_redirected_to warden_path

    get warden_path
    assert_contain 'Invalid email or password.'
  end

  test 'render 404 on roles without permission' do
    get "admin_area/password/new"
    assert_response :not_found
    assert_not_contain 'Send me reset password instructions'
  end
end
