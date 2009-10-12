require 'test/test_helper'

class UsersPasswordRecoveryTest < ActionController::IntegrationTest

  def visit_new_password_path
    visit new_user_session_path
    click_link 'Forgot password?'
  end

  def request_forgot_password(&block)
    visit_new_password_path

    assert_response :success
    assert_template 'passwords/new'
    assert_not warden.authenticated?(:user)

    fill_in 'email', :with => 'user@test.com'
    yield if block_given?
    click_button 'Send me reset password instructions'
  end

  def reset_password(options={}, &block)
    visit edit_user_password_path(:perishable_token => options[:perishable_token])
    assert_response :success
    assert_template 'passwords/edit'

    fill_in 'Password', :with => '987654321'
    fill_in 'Password confirmation', :with => '987654321'
    yield if block_given?
    click_button 'Change my password'
  end

  test 'authenticated user should not be able to visit forgot password page' do
    sign_in_as_user
    assert warden.authenticated?(:user)

    get new_user_password_path

    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'not authenticated user should be able to request a forgot password' do
    create_user
    request_forgot_password

    assert_template 'sessions/new'
    assert_contain 'You will receive an email with instructions about how to reset your password in a few minutes.'
  end

  test 'not authenticated user with invalid email should receive an error message' do
    request_forgot_password do
      fill_in 'email', :with => 'invalid.test@test.com'
    end

    assert_response :success
    assert_template 'passwords/new'
    assert_have_selector 'input[type=text][value=\'invalid.test@test.com\']'
    assert_contain 'Email not found'
  end

  test 'authenticated user should not be able to visit edit password page' do
    sign_in_as_user

    get edit_user_password_path

    assert_response :redirect
    assert_redirected_to root_path
    assert warden.authenticated?(:user)
  end

  test 'not authenticated user with invalid perishable token should not be able to change his password' do
    user = create_user
    reset_password :perishable_token => 'invalid_perishable'

    assert_response :success
    assert_template 'passwords/edit'
    assert_have_selector '#errorExplanation'
    assert_contain 'invalid confirmation'
    assert_not user.reload.valid_password?('987654321')
  end

  test 'not authenticated user with valid perisable token but invalid password should not be able to change his password' do
    user = create_user
    reset_password :perishable_token => user.perishable_token do
      fill_in 'Password confirmation', :with => 'other_password'
    end

    assert_response :success
    assert_template 'passwords/edit'
    assert_have_selector '#errorExplanation'
    assert_contain 'Password doesn\'t match confirmation'
    assert_not user.reload.valid_password?('987654321')
  end

  test 'not authenticated user with valid data should be able to change his password' do
    user = create_user
    reset_password :perishable_token => user.perishable_token

    assert_template 'sessions/new'
    assert_contain 'Your password was changed successfully.'
    assert user.reload.valid_password?('987654321')
  end
end
