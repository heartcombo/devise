require 'test/test_helper'

class ConfirmationsTest < ActionController::IntegrationTest

  test 'should be able to request a new confirmation' do
    user = create_user

    visit 'users/session/new'
    click_link 'Didn\'t receive confirmation instructions?'

    fill_in 'email', :with => user.email
    click_button 'Resend confirmation instructions'

#    assert_response :redirect
#    assert_redirected_to root_path
    assert_template 'sessions/new'
    assert_contain 'You will receive an email with instructions about how to confirm your account in a few minutes'
  end

  test 'with invalid perishable token should not be able to confirm an account' do
    visit user_confirmation_path(:perishable_token => 'invalid_perishable')

    assert_response :success
    assert_template 'confirmations/new'
    assert_have_selector '#errorExplanation'
    assert_contain 'invalid confirmation'
  end

  test 'with valid perishable token should be able to confirm an account' do
    user = create_user(:confirm => false)
    assert_not user.confirmed?

    visit user_confirmation_path(:perishable_token => user.perishable_token)

#    assert_response :redirect
    assert_template 'sessions/new'
    assert_contain 'Your account was successfully confirmed!'

    assert user.reload.confirmed?
  end

  test 'already confirmed user should not be able to confirm the account again' do
    user = create_user
    visit user_confirmation_path(:perishable_token => user.perishable_token)

    assert_template 'confirmations/new'
    assert_have_selector '#errorExplanation'
    assert_contain 'already confirmed'
  end
end
