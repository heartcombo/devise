require 'test_helper'

class ConfirmationTest < ActionController::IntegrationTest

  def visit_user_confirmation_with_token(confirmation_token)
    visit user_confirmation_path(:confirmation_token => confirmation_token)
  end

  test 'user should be able to request a new confirmation' do
    user = create_user(:confirm => false)
    ActionMailer::Base.deliveries.clear

    visit new_user_session_path
    click_link "Didn't receive confirmation instructions?"

    fill_in 'email', :with => user.email
    click_button 'Resend confirmation instructions'

    assert_current_url '/users/sign_in'
    assert_contain 'You will receive an email with instructions about how to confirm your account in a few minutes'
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test 'user with invalid confirmation token should not be able to confirm an account' do
    visit_user_confirmation_with_token('invalid_confirmation')
    assert_have_selector '#error_explanation'
    assert_contain /Confirmation token(.*)invalid/
  end

  test 'user with valid confirmation token should be able to confirm an account' do
    user = create_user(:confirm => false)
    assert_not user.confirmed?
    visit_user_confirmation_with_token(user.confirmation_token)

    assert_contain 'Your account was successfully confirmed.'
    assert_current_url '/'
    assert user.reload.confirmed?
  end

  test 'user should be redirected to a custom path after confirmation' do
    Devise::ConfirmationsController.any_instance.stubs(:after_confirmation_path_for).returns("/?custom=1")

    user = create_user(:confirm => false)
    visit_user_confirmation_with_token(user.confirmation_token)

    assert_current_url "/?custom=1"
  end

  test 'already confirmed user should not be able to confirm the account again' do
    user = create_user(:confirm => false)
    user.confirmed_at = Time.now
    user.save
    visit_user_confirmation_with_token(user.confirmation_token)

    assert_have_selector '#error_explanation'
    assert_contain 'already confirmed'
  end

  test 'already confirmed user should not be able to confirm the account again neither request confirmation' do
    user = create_user(:confirm => false)
    user.confirmed_at = Time.now
    user.save

    visit_user_confirmation_with_token(user.confirmation_token)
    assert_contain 'already confirmed'

    fill_in 'email', :with => user.email
    click_button 'Resend confirmation instructions'
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
      :failure => { :user => { :unconfirmed => "Not confirmed user" } }
    } do
      sign_in_as_user(:confirm => false)
      assert_contain 'Not confirmed user'
    end
  end

  test 'resent confirmation token with valid E-Mail in XML format should return valid response' do
    user = create_user(:confirm => false)
    post user_confirmation_path(:format => 'xml'), :user => { :email => user.email }
    assert_response :success
    assert_equal response.body, {}.to_xml
  end

  test 'resent confirmation token with invalid E-Mail in XML format should return invalid response' do
    user = create_user(:confirm => false)
    post user_confirmation_path(:format => 'xml'), :user => { :email => 'invalid.test@test.com' }
    assert_response :unprocessable_entity
    assert response.body.include? %(<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors>)
  end

  test 'confirm account with valid confirmation token in XML format should return valid response' do
    user = create_user(:confirm => false)
    get user_confirmation_path(:confirmation_token => user.confirmation_token, :format => 'xml')
    assert_response :success
    assert response.body.include? %(<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<user>)
  end

  test 'confirm account with invalid confirmation token in XML format should return invalid response' do
    user = create_user(:confirm => false)
    get user_confirmation_path(:confirmation_token => 'invalid_confirmation', :format => 'xml')
    assert_response :unprocessable_entity
    assert response.body.include? %(<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors>)
  end

  test 'request an account confirmation account with JSON, should return an empty JSON' do
    user = create_user(:confirm => false)

    post user_confirmation_path, :user => { :email => user.email }, :format => :json
    assert_response :success
    assert_equal response.body, {}.to_json
  end

  test "when in paranoid mode and with a valid e-mail, should not say that the e-mail is valid" do
    swap Devise, :paranoid => true do
      user = create_user(:confirm => false)
      visit new_user_session_path

      click_link "Didn't receive confirmation instructions?"
      fill_in 'email', :with => user.email
      click_button 'Resend confirmation instructions'

      assert_contain "If your e-mail exists on our database, you will receive an email with instructions about how to confirm your account in a few minutes."
      assert_current_url "/users/confirmation"
    end
  end

  test "when in paranoid mode and with a invalid e-mail, should not say that the e-mail is invalid" do
    swap Devise, :paranoid => true do
      visit new_user_session_path

      click_link "Didn't receive confirmation instructions?"
      fill_in 'email', :with => "idonthavethisemail@gmail.com"
      click_button 'Resend confirmation instructions'

      assert_not_contain "1 error prohibited this user from being saved:"
      assert_not_contain "Email not found"

      assert_contain "If your e-mail exists on our database, you will receive an email with instructions about how to confirm your account in a few minutes."
      assert_current_url "/users/confirmation"
    end
  end
end
