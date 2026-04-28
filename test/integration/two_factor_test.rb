# frozen_string_literal: true

require 'test_helper'

class TwoFactorAuthenticationTest < Devise::IntegrationTest
  test 'sign in redirects to two factor challenge when 2FA is enabled' do
    user = create_user_with_two_factor(otp_secret: '123456')

    visit new_user_with_two_factor_session_path
    fill_in 'email', with: user.email
    fill_in 'password', with: '12345678'
    click_button 'Log In'

    assert_not warden.authenticated?(:user_with_two_factor)
    assert_equal user.id, session["devise.two_factor.resource_id"]
  end

  test 'sign in without 2FA enabled proceeds normally' do
    user = create_user_with_two_factor(otp_secret: nil)

    visit new_user_with_two_factor_session_path
    fill_in 'email', with: user.email
    fill_in 'password', with: '12345678'
    click_button 'Log In'

    assert warden.authenticated?(:user_with_two_factor)
    assert_nil session["devise.two_factor.resource_id"]
  end

  test 'password reset with 2FA enabled redirects to two factor challenge' do
    user = create_user_with_two_factor(otp_secret: '123456')
    raw_token = user.send_reset_password_instructions

    visit edit_user_with_two_factor_password_path(reset_password_token: raw_token)
    fill_in 'New password', with: 'newpassword123'
    fill_in 'Confirm new password', with: 'newpassword123'
    click_button 'Change my password'

    assert_not warden.authenticated?(:user_with_two_factor)
    assert session["devise.two_factor.resource_id"]
  end

  test 'password reset without 2FA signs in directly' do
    user = create_user_with_two_factor(otp_secret: nil)
    raw_token = user.send_reset_password_instructions

    visit edit_user_with_two_factor_password_path(reset_password_token: raw_token)
    fill_in 'New password', with: 'newpassword123'
    fill_in 'Confirm new password', with: 'newpassword123'
    click_button 'Change my password'

    assert warden.authenticated?(:user_with_two_factor)
  end

  test 'two-factor routes generate correct paths' do
    assert_equal '/user_with_two_factors/two_factor/test_otp/new',
      user_with_two_factor_new_two_factor_test_otp_path
    assert_equal '/user_with_two_factors/two_factor',
      user_with_two_factor_two_factor_path
  end

  test 'full two-factor sign-in: password -> challenge -> OTP -> authenticated' do
    user = create_user_with_two_factor(otp_secret: '123456')

    # Step 1: Submit password
    post user_with_two_factor_session_path, params: {
      user_with_two_factor: { email: user.email, password: '12345678' }
    }

    # Step 2: Redirected to the default 2FA method's challenge page
    assert_redirected_to user_with_two_factor_new_two_factor_test_otp_path
    follow_redirect!
    assert_response :success

    # Step 3: Submit correct OTP
    post user_with_two_factor_two_factor_path, params: {
      otp_attempt: user.otp_secret
    }

    # Step 4: Authenticated and redirected to after_sign_in_path
    assert_response :redirect
    assert warden.authenticated?(:user_with_two_factor)
  end

  test 'two-factor sign-in with wrong OTP recalls challenge page' do
    user = create_user_with_two_factor(otp_secret: '123456')

    post user_with_two_factor_session_path, params: {
      user_with_two_factor: { email: user.email, password: '12345678' }
    }
    assert_redirected_to user_with_two_factor_new_two_factor_test_otp_path

    # Submit wrong OTP
    post user_with_two_factor_two_factor_path, params: {
      otp_attempt: 'wrong'
    }

    # Should recall (re-render) the challenge page, not redirect
    assert_response :success
    assert_not warden.authenticated?(:user_with_two_factor)
  end

  test 'two-factor sign-in with expired session does not authenticate' do
    user = create_user_with_two_factor(otp_secret: '123456')

    post user_with_two_factor_session_path, params: {
      user_with_two_factor: { email: user.email, password: '12345678' }
    }
    assert_redirected_to user_with_two_factor_new_two_factor_test_otp_path

    # Simulate session expiration between password and OTP submission
    reset!

    post user_with_two_factor_two_factor_path, params: {
      otp_attempt: user.otp_secret
    }

    assert_not warden.authenticated?(:user_with_two_factor)
  end

  test 'visiting two-factor challenge page without sign-in redirects to login' do
    get user_with_two_factor_new_two_factor_test_otp_path

    assert_redirected_to new_user_with_two_factor_session_path
    assert_not warden.authenticated?(:user_with_two_factor)
  end

  private

  def create_user_with_two_factor(attributes = {})
    UserWithTwoFactor.create!(
      username: 'usertest',
      email: generate_unique_email,
      password: '12345678',
      password_confirmation: '12345678',
      **attributes
    )
  end
end
