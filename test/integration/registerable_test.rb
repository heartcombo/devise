require 'test_helper'

class RegistrationTest < ActionDispatch::IntegrationTest

  test 'a guest admin should be able to sign in successfully' do
    get new_admin_session_path
    click_link 'Sign up'

    assert_template 'registrations/new'

    fill_in 'email', :with => 'new_user@test.com'
    fill_in 'password', :with => 'new_user123'
    fill_in 'password confirmation', :with => 'new_user123'
    click_button 'Sign up'

    assert_contain 'You have signed up successfully'
    assert warden.authenticated?(:admin)
    assert_current_url "/admin_area/home"

    admin = Admin.order(:id).last
    assert_equal admin.email, 'new_user@test.com'
  end

  test 'a guest admin should be able to sign in and be redirected to a custom location' do
    Devise::RegistrationsController.any_instance.stubs(:after_sign_up_path_for).returns("/?custom=1")
    get new_admin_session_path
    click_link 'Sign up'

    fill_in 'email', :with => 'new_user@test.com'
    fill_in 'password', :with => 'new_user123'
    fill_in 'password confirmation', :with => 'new_user123'
    click_button 'Sign up'

    assert_contain 'Welcome! You have signed up successfully.'
    assert warden.authenticated?(:admin)
    assert_current_url "/?custom=1"
  end

  def user_sign_up
    ActionMailer::Base.deliveries.clear

    get new_user_registration_path

    fill_in 'email', :with => 'new_user@test.com'
    fill_in 'password', :with => 'new_user123'
    fill_in 'password confirmation', :with => 'new_user123'
    click_button 'Sign up'
  end

  test 'a guest user should be able to sign up successfully and be blocked by confirmation' do
    user_sign_up

    assert_contain 'A message with a confirmation link has been sent to your email address. Please open the link to activate your account.'
    assert_not_contain 'You have to confirm your account before continuing'
    assert_current_url "/"

    assert_not warden.authenticated?(:user)

    user = User.order(:id).last
    assert_equal user.email, 'new_user@test.com'
    assert_not user.confirmed?
  end

  test 'a guest user should receive the confirmation instructions from the default mailer' do
    user_sign_up
    assert_equal ['please-change-me@config-initializers-devise.com'], ActionMailer::Base.deliveries.first.from
  end

  test 'a guest user should receive the confirmation instructions from a custom mailer' do
    User.any_instance.stubs(:devise_mailer).returns(Users::Mailer)
    user_sign_up
    assert_equal ['custom@example.com'], ActionMailer::Base.deliveries.first.from
  end

  test 'a guest user should be blocked by confirmation and redirected to a custom path' do
    Devise::RegistrationsController.any_instance.stubs(:after_inactive_sign_up_path_for).returns("/?custom=1")
    get new_user_registration_path

    fill_in 'email', :with => 'new_user@test.com'
    fill_in 'password', :with => 'new_user123'
    fill_in 'password confirmation', :with => 'new_user123'
    click_button 'Sign up'

    assert_current_url "/?custom=1"
    assert_not warden.authenticated?(:user)
  end

  test 'a guest user cannot sign up with invalid information' do
    # Dirty tracking behavior prevents email validations from being applied:
    #    https://github.com/mongoid/mongoid/issues/756
    (pending "Fails on Mongoid < 2.1"; break) if defined?(Mongoid) && Mongoid::VERSION.to_f < 2.1

    get new_user_registration_path

    fill_in 'email', :with => 'invalid_email'
    fill_in 'password', :with => 'new_user123'
    fill_in 'password confirmation', :with => 'new_user321'
    click_button 'Sign up'

    assert_template 'registrations/new'
    assert_have_selector '#error_explanation'
    assert_contain "Email is invalid"
    assert_contain Devise.rails4? ?
      "Password confirmation doesn't match Password" : "Password doesn't match confirmation"
    assert_contain "2 errors prohibited"
    assert_nil User.first

    assert_not warden.authenticated?(:user)
  end

  test 'a guest should not sign up with email/password that already exists' do
    # Dirty tracking behavior prevents email validations from being applied:
    #    https://github.com/mongoid/mongoid/issues/756
    (pending "Fails on Mongoid < 2.1"; break) if defined?(Mongoid) && Mongoid::VERSION.to_f < 2.1

    create_user
    get new_user_registration_path

    fill_in 'email', :with => 'user@test.com'
    fill_in 'password', :with => '123456'
    fill_in 'password confirmation', :with => '123456'
    click_button 'Sign up'

    assert_current_url '/users'
    assert_contain(/Email.*already.*taken/)

    assert_not warden.authenticated?(:user)
  end

  test 'a guest should not be able to change account' do
    get edit_user_registration_path
    assert_redirected_to new_user_session_path
    follow_redirect!
    assert_contain 'You need to sign in or sign up before continuing.'
  end

  test 'a signed in user should not be able to access sign up' do
    sign_in_as_user
    get new_user_registration_path
    assert_redirected_to root_path
  end

  test 'a signed in user should be able to edit his account' do
    sign_in_as_user
    get edit_user_registration_path

    fill_in 'email', :with => 'user.new@example.com'
    fill_in 'current password', :with => '12345678'
    click_button 'Update'

    assert_current_url '/'
    assert_contain 'You updated your account successfully.'

    assert_equal "user.new@example.com", User.first.email
  end

  test 'a signed in user should still be able to use the website after changing his password' do
    sign_in_as_user
    get edit_user_registration_path

    fill_in 'password', :with => '1234567890'
    fill_in 'password confirmation', :with => '1234567890'
    fill_in 'current password', :with => '12345678'
    click_button 'Update'

    assert_contain 'You updated your account successfully.'
    get users_path
    assert warden.authenticated?(:user)
  end

  test 'a signed in user should not change his current user with invalid password' do
    sign_in_as_user
    get edit_user_registration_path

    fill_in 'email', :with => 'user.new@example.com'
    fill_in 'current password', :with => 'invalid'
    click_button 'Update'

    assert_template 'registrations/edit'
    assert_contain 'user@test.com'
    assert_have_selector 'form input[value="user.new@example.com"]'

    assert_equal "user@test.com", User.first.email
  end

  test 'a signed in user should be able to edit his password' do
    sign_in_as_user
    get edit_user_registration_path

    fill_in 'password', :with => 'pass1234'
    fill_in 'password confirmation', :with => 'pass1234'
    fill_in 'current password', :with => '12345678'
    click_button 'Update'

    assert_current_url '/'
    assert_contain 'You updated your account successfully.'

    assert User.first.valid_password?('pass1234')
  end

  test 'a signed in user should not be able to edit his password with invalid confirmation' do
    sign_in_as_user
    get edit_user_registration_path

    fill_in 'password', :with => 'pas123'
    fill_in 'password confirmation', :with => ''
    fill_in 'current password', :with => '12345678'
    click_button 'Update'

    assert_contain Devise.rails4? ?
      "Password confirmation doesn't match Password" : "Password doesn't match confirmation"
    assert_not User.first.valid_password?('pas123')
  end

  test 'a signed in user should be able to cancel his account' do
    sign_in_as_user
    get edit_user_registration_path

    click_button "Cancel my account"
    assert_contain "Bye! Your account was successfully cancelled. We hope to see you again soon."

    assert User.all.empty?
  end

  test 'a user should be able to cancel sign up by deleting data in the session' do
    get "/set"
    assert_equal "something", @request.session["devise.foo_bar"]

    get "/users/sign_up"
    assert_equal "something", @request.session["devise.foo_bar"]

    get "/users/cancel"
    assert_nil @request.session["devise.foo_bar"]
    assert_redirected_to new_user_registration_path
  end

  test 'a user with XML sign up stub' do
    get new_user_registration_path(:format => 'xml')
    assert_response :success
    assert_match %(<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<user>), response.body
    assert_no_match(/<confirmation-token/, response.body)
  end

  test 'a user with JSON sign up stub' do
    get new_user_registration_path(:format => 'json')
    assert_response :success
    assert_match %({"user":), response.body
    assert_no_match(/"confirmation_token"/, response.body)
  end

  test 'an admin sign up with valid information in XML format should return valid response' do
    post admin_registration_path(:format => 'xml'), :admin => { :email => 'new_user@test.com', :password => 'new_user123', :password_confirmation => 'new_user123' }
    assert_response :success
    assert response.body.include? %(<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<admin>)

    admin = Admin.order(:id).last
    assert_equal admin.email, 'new_user@test.com'
  end

  test 'a user sign up with valid information in XML format should return valid response' do
    post user_registration_path(:format => 'xml'), :user => { :email => 'new_user@test.com', :password => 'new_user123', :password_confirmation => 'new_user123' }
    assert_response :success
    assert response.body.include? %(<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<user>)

    user = User.order(:id).last
    assert_equal user.email, 'new_user@test.com'
  end

  test 'a user sign up with invalid information in XML format should return invalid response' do
    post user_registration_path(:format => 'xml'), :user => { :email => 'new_user@test.com', :password => 'new_user123', :password_confirmation => 'invalid' }
    assert_response :unprocessable_entity
    assert response.body.include? %(<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors>)
  end

  test 'a user update information with valid data in XML format should return valid response' do
    user = sign_in_as_user
    put user_registration_path(:format => 'xml'), :user => { :current_password => '12345678', :email => 'user.new@test.com' }
    assert_response :success
    assert_equal user.reload.email, 'user.new@test.com'
  end

  test 'a user update information with invalid data in XML format should return invalid response' do
    user = sign_in_as_user
    put user_registration_path(:format => 'xml'), :user => { :current_password => 'invalid', :email => 'user.new@test.com' }
    assert_response :unprocessable_entity
    assert_equal user.reload.email, 'user@test.com'
  end

  test 'a user cancel his account in XML format should return valid response' do
    sign_in_as_user
    delete user_registration_path(:format => 'xml')
    assert_response :success
    assert_equal User.count, 0
  end
end

class ReconfirmableRegistrationTest < ActionDispatch::IntegrationTest
  test 'a signed in admin should see a more appropriate flash message when editing his account if reconfirmable is enabled' do
    sign_in_as_admin
    get edit_admin_registration_path

    fill_in 'email', :with => 'admin.new@example.com'
    fill_in 'current password', :with => '123456'
    click_button 'Update'

    assert_current_url '/admin_area/home'
    assert_contain 'but we need to verify your new email address'
    assert_equal 'admin.new@example.com', Admin.first.unconfirmed_email

    get edit_admin_registration_path
    assert_contain 'Currently waiting confirmation for: admin.new@example.com'
  end

  test 'a signed in admin should not see a reconfirmation message if they did not change their password' do
    sign_in_as_admin
    get edit_admin_registration_path

    fill_in 'password', :with => 'pas123'
    fill_in 'password confirmation', :with => 'pas123'
    fill_in 'current password', :with => '123456'
    click_button 'Update'

    assert_current_url '/admin_area/home'
    assert_contain 'You updated your account successfully.'

    assert Admin.first.valid_password?('pas123')
  end

  test 'a signed in admin should not see a reconfirmation message if he did not change his email, despite having an unconfirmed email' do
    sign_in_as_admin

    get edit_admin_registration_path
    fill_in 'email', :with => 'admin.new@example.com'
    fill_in 'current password', :with => '123456'
    click_button 'Update'

    get edit_admin_registration_path
    fill_in 'password', :with => 'pas123'
    fill_in 'password confirmation', :with => 'pas123'
    fill_in 'current password', :with => '123456'
    click_button 'Update'

    assert_current_url '/admin_area/home'
    assert_contain 'You updated your account successfully.'

    assert_equal "admin.new@example.com", Admin.first.unconfirmed_email
    assert Admin.first.valid_password?('pas123')
  end
end
