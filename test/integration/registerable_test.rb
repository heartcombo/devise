require 'test_helper'

class RegistrationTest < ActionController::IntegrationTest

  test 'a guest admin should be able to sign in successfully' do
    get new_admin_session_path
    click_link 'Sign up'

    assert_template 'registrations/new'

    fill_in 'email', :with => 'new_user@test.com'
    fill_in 'password', :with => 'new_user123'
    fill_in 'password confirmation', :with => 'new_user123'
    click_button 'Sign up'

    assert_contain 'You have signed up successfully.'
    assert warden.authenticated?(:admin)

    admin = Admin.last :order => "id"
    assert_equal admin.email, 'new_user@test.com'
  end

  test 'a guest user should be able to sign up successfully and be blocked by confirmation' do
    get new_user_registration_path

    fill_in 'email', :with => 'new_user@test.com'
    fill_in 'password', :with => 'new_user123'
    fill_in 'password confirmation', :with => 'new_user123'
    click_button 'Sign up'

    assert_contain 'You have signed up successfully'
    assert_contain 'Sign in'
    assert_not_contain 'You have to confirm your account before continuing'

    assert_not warden.authenticated?(:user)

    user = User.last :order => "id"
    assert_equal user.email, 'new_user@test.com'
    assert_not user.confirmed?
  end

  test 'a guest user cannot sign up with invalid information' do
    get new_user_registration_path

    fill_in 'email', :with => 'invalid_email'
    fill_in 'password', :with => 'new_user123'
    fill_in 'password confirmation', :with => 'new_user321'
    click_button 'Sign up'

    assert_template 'registrations/new'
    assert_have_selector '#error_explanation'
    assert_contain "Email is invalid"
    assert_contain "Password doesn't match confirmation"
    assert_nil User.first

    assert_not warden.authenticated?(:user)
  end

  test 'a guest should not sign up with email/password that already exists' do
    user = create_user
    get new_user_registration_path

    fill_in 'email', :with => 'user@test.com'
    fill_in 'password', :with => '123456'
    fill_in 'password confirmation', :with => '123456'
    click_button 'Sign up'

    assert_current_url '/users'
    assert_contain(/Email .* already .* taken/)

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

    fill_in 'email', :with => 'user.new@email.com'
    fill_in 'current password', :with => '123456'
    click_button 'Update'

    assert_current_url '/'
    assert_contain 'You updated your account successfully.'

    assert_equal "user.new@email.com", User.first.email
  end

  test 'a signed in user should not change his current user with invalid password' do
    sign_in_as_user
    get edit_user_registration_path

    fill_in 'email', :with => 'user.new@email.com'
    fill_in 'current password', :with => 'invalid'
    click_button 'Update'

    assert_template 'registrations/edit'
    assert_contain 'user@test.com'
    assert_have_selector 'form input[value="user.new@email.com"]'

    assert_equal "user@test.com", User.first.email
  end

  test 'a signed in user should be able to edit his password' do
    sign_in_as_user
    get edit_user_registration_path

    fill_in 'password', :with => 'pas123'
    fill_in 'password confirmation', :with => 'pas123'
    fill_in 'current password', :with => '123456'
    click_button 'Update'

    assert_current_url '/'
    assert_contain 'You updated your account successfully.'

    assert User.first.valid_password?('pas123')
  end

  test 'a signed in user should not be able to edit his password with invalid confirmation' do
    sign_in_as_user
    get edit_user_registration_path

    fill_in 'password', :with => 'pas123'
    fill_in 'password confirmation', :with => ''
    fill_in 'current password', :with => '123456'
    click_button 'Update'

    assert_contain "Password doesn't match confirmation"
    assert_not User.first.valid_password?('pas123')
  end

  test 'a signed in user should be able to cancel his account' do
    sign_in_as_user
    get edit_user_registration_path

    click_link "Cancel my account", :method => :delete
    assert_contain "Bye! Your account was successfully cancelled. We hope to see you again soon."

    assert User.all.empty?
  end

  test 'a user should be able to cancel sign up by deleting data in the session' do
    get "/set"
    assert_equal "something", @request.session["user_facebook_oauth_token"]

    get "/users/sign_up"
    assert_equal "something", @request.session["user_facebook_oauth_token"]

    get "/users/cancel"
    assert_nil @request.session["user_facebook_oauth_token"]
    assert_redirected_to new_user_registration_path
  end
end
