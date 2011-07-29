require 'test_helper'

class PasswordTest < ActionController::IntegrationTest

  def visit_new_password_path
    visit new_user_session_path
    click_link 'Forgot your password?'
  end

  def request_forgot_password(&block)
    visit_new_password_path
    assert_response :success
    assert_not warden.authenticated?(:user)

    fill_in 'email', :with => 'user@test.com'
    yield if block_given?
    click_button 'Send me reset password instructions'
  end

  def reset_password(options={}, &block)
    visit edit_user_password_path(:reset_password_token => options[:reset_password_token]) unless options[:visit] == false
    assert_response :success

    fill_in 'New password', :with => '987654321'
    fill_in 'Confirm new password', :with => '987654321'
    yield if block_given?
    click_button 'Change my password'
  end

  test 'reset password with email of different case should succeed when email is in the list of case insensitive keys' do
    create_user(:email => 'Foo@Bar.com')

    request_forgot_password do
      fill_in 'email', :with => 'foo@bar.com'
    end

    assert_current_url '/users/sign_in'
    assert_contain 'You will receive an email with instructions about how to reset your password in a few minutes.'
  end

  test 'reset password with email of different case should fail when email is NOT the list of case insensitive keys' do
    swap Devise, :case_insensitive_keys => [] do
      create_user(:email => 'Foo@Bar.com')

      request_forgot_password do
        fill_in 'email', :with => 'foo@bar.com'
      end

      assert_response :success
      assert_current_url '/users/password'
      assert_have_selector "input[type=email][value='foo@bar.com']"
      assert_contain 'not found'
    end
  end

  test 'reset password with email with extra whitespace should succeed when email is in the list of strip whitespace keys' do
    create_user(:email => 'foo@bar.com')

    request_forgot_password do
      fill_in 'email', :with => ' foo@bar.com '
    end

    assert_current_url '/users/sign_in'
    assert_contain 'You will receive an email with instructions about how to reset your password in a few minutes.'
  end

  test 'reset password with email with extra whitespace should fail when email is NOT the list of strip whitespace keys' do
    swap Devise, :strip_whitespace_keys => [] do
      create_user(:email => 'foo@bar.com')

      request_forgot_password do
        fill_in 'email', :with => ' foo@bar.com '
      end

      assert_response :success
      assert_current_url '/users/password'
      assert_have_selector "input[type=email][value=' foo@bar.com ']"
      assert_contain 'not found'
    end
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

    assert_current_url '/users/sign_in'
    assert_contain 'You will receive an email with instructions about how to reset your password in a few minutes.'
  end

  test 'not authenticated user with invalid email should receive an error message' do
    request_forgot_password do
      fill_in 'email', :with => 'invalid.test@test.com'
    end

    assert_response :success
    assert_current_url '/users/password'
    assert_have_selector "input[type=email][value='invalid.test@test.com']"
    assert_contain 'not found'
  end

  test 'authenticated user should not be able to visit edit password page' do
    sign_in_as_user
    get edit_user_password_path
    assert_response :redirect
    assert_redirected_to root_path
    assert warden.authenticated?(:user)
  end

  test 'not authenticated user with invalid reset password token should not be able to change his password' do
    user = create_user
    reset_password :reset_password_token => 'invalid_reset_password'

    assert_response :success
    assert_current_url '/users/password'
    assert_have_selector '#error_explanation'
    assert_contain /Reset password token(.*)invalid/
    assert_not user.reload.valid_password?('987654321')
  end

  test 'not authenticated user with valid reset password token but invalid password should not be able to change his password' do
    user = create_user
    request_forgot_password
    reset_password :reset_password_token => user.reload.reset_password_token do
      fill_in 'Confirm new password', :with => 'other_password'
    end

    assert_response :success
    assert_current_url '/users/password'
    assert_have_selector '#error_explanation'
    assert_contain 'Password doesn\'t match confirmation'
    assert_not user.reload.valid_password?('987654321')
  end

  test 'not authenticated user with valid data should be able to change his password' do
    user = create_user
    request_forgot_password
    reset_password :reset_password_token => user.reload.reset_password_token

    assert_current_url '/'
    assert_contain 'Your password was changed successfully.'
    assert user.reload.valid_password?('987654321')
  end

  test 'after entering invalid data user should still be able to change his password' do
    user = create_user
    request_forgot_password
    reset_password :reset_password_token => user.reload.reset_password_token do
      fill_in 'Confirm new password', :with => 'other_password'
    end
    assert_response :success
    assert_have_selector '#error_explanation'
    assert_not user.reload.valid_password?('987654321')

    reset_password :reset_password_token => user.reload.reset_password_token, :visit => false
    assert_contain 'Your password was changed successfully.'
    assert user.reload.valid_password?('987654321')
  end

  test 'sign in user automatically after changing its password' do
    user = create_user
    request_forgot_password
    reset_password :reset_password_token => user.reload.reset_password_token

    assert warden.authenticated?(:user)
  end

  test 'does not sign in user automatically after changing its password if its not active' do
    user = create_user(:confirm => false)
    request_forgot_password
    reset_password :reset_password_token => user.reload.reset_password_token

    assert_equal new_user_session_path, @request.path
    assert !warden.authenticated?(:user)
  end

  test 'reset password request with valid E-Mail in XML format should return valid response' do
    create_user
    post user_password_path(:format => 'xml'), :user => {:email => "user@test.com"}
    assert_response :success
    assert_equal response.body, { }.to_xml
  end

  test 'reset password request with invalid E-Mail in XML format should return valid response' do
    create_user
    post user_password_path(:format => 'xml'), :user => {:email => "invalid.test@test.com"}
    assert_response :unprocessable_entity
    assert response.body.include? %(<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors>)
  end

  test 'change password with valid parameters in XML format should return valid response' do
    user = create_user
    request_forgot_password
    put user_password_path(:format => 'xml'), :user => {:reset_password_token => user.reload.reset_password_token, :password => '987654321', :password_confirmation => '987654321'}
    assert_response :success
    assert warden.authenticated?(:user)
  end

  test 'change password with invalid token in XML format should return invalid response' do
    user = create_user
    request_forgot_password
    put user_password_path(:format => 'xml'), :user => {:reset_password_token => 'invalid.token', :password => '987654321', :password_confirmation => '987654321'}
    assert_response :unprocessable_entity
    assert response.body.include? %(<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors>)
  end

  test 'change password with invalid new password in XML format should return invalid response' do
    user = create_user
    request_forgot_password
    put user_password_path(:format => 'xml'), :user => {:reset_password_token => user.reload.reset_password_token, :password => '', :password_confirmation => '987654321'}
    assert_response :unprocessable_entity
    assert response.body.include? %(<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors>)
  end

  test "when using json requests to ask a confirmable request, should not return the object" do
    user = create_user(:confirm => false)

    post user_password_path(:format => :json), :user => { :email => user.email }

    assert_response :success
    assert_equal response.body, "{}"
  end

  test "when in paranoid mode and with an invalid e-mail, asking to reset a password should display a message that does not indicates that the e-mail does not exists in the database" do
    swap Devise, :paranoid => true do
      visit_new_password_path
      fill_in "email", :with => "arandomemail@test.com"
      click_button 'Send me reset password instructions'

      assert_not_contain "1 error prohibited this user from being saved:"
      assert_not_contain "Email not found"
      assert_contain "If your e-mail exists on our database, you will receive a password recovery link on your e-mail"
      assert_current_url "/users/password"
    end
  end

  test "when in paranoid mode and with a valid e-mail, asking to reset password should display a message that does not indicates that the email exists in the database and redirect to the failure route" do
    swap Devise, :paranoid => true do
      user = create_user
      visit_new_password_path
      fill_in 'email', :with => user.email
      click_button 'Send me reset password instructions'

      assert_contain "If your e-mail exists on our database, you will receive a password recovery link on your e-mail"
      assert_current_url "/users/password"
    end
  end
end
