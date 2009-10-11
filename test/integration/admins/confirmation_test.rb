require 'test/test_helper'

class AdminsConfirmationTest < ActionController::IntegrationTest

  test 'admin should be able to request a new confirmation' do
    admin = create_admin
    ActionMailer::Base.deliveries.clear

    visit new_admin_session_path
    click_link 'Didn\'t receive confirmation instructions?'

    fill_in 'email', :with => admin.email
    click_button 'Resend confirmation instructions'

    assert_template 'sessions/new'
    assert_contain 'You will receive an email with instructions about how to confirm your account in a few minutes'
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test 'admin with invalid perishable token should not be able to confirm an account' do
    visit user_confirmation_path(:perishable_token => 'invalid_perishable')

    assert_response :success
    assert_template 'confirmations/new'
    assert_have_selector '#errorExplanation'
    assert_contain 'invalid confirmation'
  end

  test 'admin with valid perishable token should be able to confirm an account' do
    admin = create_admin(:confirm => false)
    assert_not admin.confirmed?

    visit admin_confirmation_path(:perishable_token => admin.perishable_token)

    assert_template 'sessions/new'
    assert_contain 'Your account was successfully confirmed!'

    assert admin.reload.confirmed?
  end

  test 'admin already confirmed user should not be able to confirm the account again' do
    admin = create_admin
    visit admin_confirmation_path(:perishable_token => admin.perishable_token)

    assert_template 'confirmations/new'
    assert_have_selector '#errorExplanation'
    assert_contain 'already confirmed'
  end
end
