require 'test/test_helper'

class RegistrationTest < ActionController::IntegrationTest

  test 'a guest admin should be able to sign in successfully' do
    visit new_admin_session_path
    click_link 'Sign up'

    assert_template 'registrations/new'

    fill_in 'email', :with => 'new_user@test.com'
    fill_in 'password', :with => 'new_user123'
    fill_in 'password confirmation', :with => 'new_user123'
    click_button 'Register'

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
    click_button 'Register'

    follow_redirect!

    assert_contain 'You have to confirm your account before continuing.'
    assert_not warden.authenticated?(:user)

    user = User.last
    assert_equal user.email, 'new_user@test.com'
  end

  test 'a guest user cannot sign up with invalid information' do
    visit new_user_session_path
    click_link 'Sign up'

    fill_in 'email', :with => 'invalid_email'
    fill_in 'password', :with => 'new_user123'
    fill_in 'password confirmation', :with => 'new_user321'
    click_button 'Register'

    assert_template 'registrations/new'
    assert_have_selector '#errorExplanation'
    assert_contain "Email is invalid"
    assert_contain "Password doesn't match confirmation"
    assert_nil User.first
  end
end
