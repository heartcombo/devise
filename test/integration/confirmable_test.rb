require 'test/test_helper'

class ConfirmationTest < ActionController::IntegrationTest

  def visit_user_confirmation_with_token(confirmation_token)
    visit user_confirmation_path(:confirmation_token => confirmation_token)
  end

  test 'user should be able to request a new confirmation' do
    user = create_user(:confirm => false)
    ActionMailer::Base.deliveries.clear

    visit new_user_session_path
    click_link 'Didn\'t receive confirmation instructions?'

    fill_in 'email', :with => user.email
    click_button 'Resend confirmation instructions'

    assert_template 'sessions/new'
    assert_contain 'You will receive an email with instructions about how to confirm your account in a few minutes'
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test 'user with invalid confirmation token should not be able to confirm an account' do
    visit_user_confirmation_with_token('invalid_confirmation')

    assert_response :success
    assert_template 'confirmations/new'
    assert_have_selector '#errorExplanation'
    assert_contain /Confirmation token(.*)invalid/
  end

  test 'user with valid confirmation token should be able to confirm an account' do
    user = create_user(:confirm => false)
    assert_not user.confirmed?

    visit_user_confirmation_with_token(user.confirmation_token)

    assert_template 'home/index'
    assert_contain 'Your account was successfully confirmed.'

    assert user.reload.confirmed?
  end

  test 'user already confirmed user should not be able to confirm the account again' do
    user = create_user(:confirm => false)
    user.confirmed_at = Time.now
    user.save
    visit_user_confirmation_with_token(user.confirmation_token)

    assert_template 'confirmations/new'
    assert_have_selector '#errorExplanation'
    assert_contain 'already confirmed'
  end

  test 'sign in user automatically after confirming it\'s email' do
    user = create_user(:confirm => false)
    visit_user_confirmation_with_token(user.confirmation_token)

    assert warden.authenticated?(:user)
  end

  test 'increases sign count when signed in through confirmation' do
    user = create_user(:confirm => false)
    visit_user_confirmation_with_token(user.confirmation_token)

    user.reload
    assert_equal 1, user.sign_in_count
  end

  test 'not confirmed user with setup to block without confirmation should not be able to sign in' do
    swap Devise, :confirm_within => 0.days do
      sign_in_as_user(:confirm => false)

      assert_contain 'You have to confirm your account before continuing'
      assert_not warden.authenticated?(:user)
    end
  end

  test 'not confirmed user but configured with some days to confirm should be able to sign in' do
    swap Devise, :confirm_within => 1.day do
      sign_in_as_user(:confirm => false)

      assert_response :success
      assert warden.authenticated?(:user)
    end
  end

  test 'error message is configurable by resource name' do
    store_translations :en, :devise => {
      :sessions => { :admin => { :unconfirmed => "Not confirmed user" } }
    } do
      get new_admin_session_path(:unconfirmed => true)
      assert_contain 'Not confirmed user'
    end
  end
end
