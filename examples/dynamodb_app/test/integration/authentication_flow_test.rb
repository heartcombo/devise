# frozen_string_literal: true

require "test_helper"

# Walks through the 7 Devise modules supported on DynamoDB, using the HTTP
# endpoints of the application.
class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  PASSWORD = "s3cret-password"

  test "sign up, confirm (confirmable), sign in (trackable) and sign out" do
    sign_up "alice@example.com"
    user = User.find_for_authentication(email: "alice@example.com")
    assert user, "the user is stored in DynamoDB"
    assert_not user.confirmed?

    # Unconfirmed users can't sign in.
    sign_in "alice@example.com"
    assert_redirected_to new_user_session_path

    get user_confirmation_path(confirmation_token: token_from_last_email)
    assert_redirected_to new_user_session_path
    assert user.reload.confirmed?

    sign_in "alice@example.com"
    assert_redirected_to root_path
    get dashboard_path
    assert_response :success

    user.reload
    assert_equal 1, user.sign_in_count
    assert_not_nil user.current_sign_in_at
    assert_equal "127.0.0.1", user.current_sign_in_ip

    delete destroy_user_session_path
    get dashboard_path
    assert_redirected_to new_user_session_path
  end

  test "email uniqueness is validated, case-insensitively (validatable)" do
    create_confirmed_user "bob@example.com"
    sign_up "BOB@example.com"
    assert_response :unprocessable_content
    assert_match "Email has already been taken", response.body
    assert_equal 1, User.to_adapter.find_all.size
  end

  test "password reset (recoverable)" do
    create_confirmed_user "carol@example.com"
    post user_password_path, params: { user: { email: "carol@example.com" } }
    assert_redirected_to new_user_session_path

    put user_password_path, params: { user: {
      reset_password_token: token_from_last_email, password: "new-password", password_confirmation: "new-password"
    } }
    assert_redirected_to root_path
    assert User.find_for_authentication(email: "carol@example.com").valid_password?("new-password")
  end

  test "remember me cookie signs the user back in (rememberable)" do
    create_confirmed_user "dave@example.com"
    sign_in "dave@example.com", remember_me: "1"
    assert cookies["remember_user_token"].present?

    # Drop the session but keep the remember cookie.
    cookies.delete("_dynamodb_app_session")
    get dashboard_path
    assert_response :success
  end

  test "account is locked after too many failed attempts and unlocked by email (lockable)" do
    user = create_confirmed_user "erin@example.com"
    Devise.maximum_attempts.times { sign_in "erin@example.com", password: "wrong" }
    assert user.reload.access_locked?
    assert_equal Devise.maximum_attempts, user.failed_attempts

    sign_in "erin@example.com"
    assert_match "Your account is locked.", response.body
    get dashboard_path
    assert_redirected_to new_user_session_path

    get user_unlock_path(unlock_token: token_from_last_email)
    assert_not user.reload.access_locked?
    sign_in "erin@example.com"
    # Back to the page that required authentication.
    assert_redirected_to dashboard_path
  end

  test "changing email requires reconfirmation (confirmable with reconfirmable)" do
    user = create_confirmed_user "frank@example.com"
    sign_in "frank@example.com"
    put user_registration_path, params: { user: { email: "frank.new@example.com", current_password: PASSWORD } }
    assert_redirected_to root_path

    user.reload
    assert_equal "frank@example.com", user.email
    assert_equal "frank.new@example.com", user.unconfirmed_email

    get user_confirmation_path(confirmation_token: token_from_last_email)
    assert_equal "frank.new@example.com", user.reload.email
  end

  private

  def sign_up(email)
    post user_registration_path, params: { user: { email: email, password: PASSWORD, password_confirmation: PASSWORD } }
  end

  def sign_in(email, password: PASSWORD, remember_me: "0")
    post user_session_path, params: { user: { email: email, password: password, remember_me: remember_me } }
  end

  def create_confirmed_user(email)
    User.new(email: email, password: PASSWORD, password_confirmation: PASSWORD).tap do |user|
      user.skip_confirmation!
      user.save!
    end
  end

  def token_from_last_email
    ActionMailer::Base.deliveries.last.body.to_s[/token=([^"&]+)/, 1]
  end
end
