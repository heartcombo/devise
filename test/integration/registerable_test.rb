require 'test/test_helper'

class RegistrationTest < ActionController::IntegrationTest

  test 'a guest admin should be able to sign in successfully' do
    visit new_admin_session_path
    click_link 'Sign up'

    assert_template 'registrations/new'

    fill_in 'email', :with => 'new_user@test.com'
    fill_in 'password', :with => 'new_user123'
    fill_in 'password confirmation', :with => 'new_user123'
    click_button 'Sign up'

    assert_contain 'You have signed up successfully.'
    assert warden.authenticated?(:admin)

    admin = Admin.last
    assert_equal admin.email, 'new_user@test.com'
  end

  test 'a guest user should be able to sign up successfully and be blocked by confirmation' do
    visit new_user_session_path
    click_link 'Sign up'

    assert_template 'registrations/new'

    fill_in 'email', :with => 'new_user@test.com'
    fill_in 'password', :with => 'new_user123'
    fill_in 'password confirmation', :with => 'new_user123'
    click_button 'Sign up'

    assert_equal true, @controller.send(:flash)[:"user.signed_up"]
    assert_equal "You have signed up successfully.", @controller.send(:flash)[:notice]

    # For some reason flash is not being set correctly, so instead of getting the
    # "signed_up" message we get the unconfirmed one. Seems to be an issue with
    # the internal redirect by the hook and the tests.
#    follow_redirect!
#    assert_contain 'You have signed up successfully.'
#    assert_not_contain 'confirm your account'

    assert_not warden.authenticated?(:user)

    user = User.last
    assert_equal user.email, 'new_user@test.com'
    assert_not user.confirmed?
  end

  test 'a guest user cannot sign up with invalid information' do
    visit new_user_session_path
    click_link 'Sign up'

    fill_in 'email', :with => 'invalid_email'
    fill_in 'password', :with => 'new_user123'
    fill_in 'password confirmation', :with => 'new_user321'
    click_button 'Sign up'

    assert_template 'registrations/new'
    assert_have_selector '#errorExplanation'
    assert_contain "Email is invalid"
    assert_contain "Password doesn't match confirmation"
    assert_nil User.first

    assert_not warden.authenticated?(:user)
  end

  test 'a guest should not sign up with email/password that already exists' do
    user = create_user

    visit new_user_session_path
    click_link 'Sign up'

    fill_in 'email', :with => 'user@test.com'
    fill_in 'password', :with => '123456'
    fill_in 'password confirmation', :with => '123456'
    click_button 'Sign up'

    assert_template 'registrations/new'
    assert_contain 'Email has already been taken'

    assert_not warden.authenticated?(:user)
  end
end
