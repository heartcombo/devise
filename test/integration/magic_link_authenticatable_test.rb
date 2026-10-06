# frozen_string_literal: true

require 'test_helper'

class MagicLinkAuthenticationTest < Devise::IntegrationTest

  def visit_new_magic_link_path
    visit new_user_session_path
    click_link 'Sign in with a magic link'
  end

  def request_magic_link(&block)
    visit_new_magic_link_path
    assert_response :success
    assert_not warden.authenticated?(:user)

    fill_in 'email', with: 'user@test.com'
    yield if block_given?

    Devise.stubs(:friendly_token).returns("abcdef")
    click_button 'Send me a magic link'
  end

  def sign_in_with_magic_link(token = "abcdef")
    visit user_magic_link_path(magic_link_token: token)
  end

  test 'authenticated user should not be able to visit magic link request page' do
    sign_in_as_user
    assert warden.authenticated?(:user)

    get new_user_magic_link_path

    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'not authenticated user should be able to request a magic link' do
    create_user
    request_magic_link

    assert_current_url '/users/sign_in'
    assert_contain 'You will receive an email with a magic link to sign in to your account in a few minutes.'
  end

  test 'magic link email should be sent to the user record email' do
    create_user
    request_magic_link

    mail = ActionMailer::Base.deliveries.last
    assert_equal ['user@test.com'], mail.to
    assert_match user_magic_link_path(magic_link_token: 'abcdef'), mail.body.encoded
  end

  test 'not authenticated user with invalid email should receive an error message' do
    request_magic_link do
      fill_in 'email', with: 'invalid.test@test.com'
    end

    assert_response :success
    assert_current_url '/users/magic_link'
    assert_have_selector "input[type=email][value='invalid.test@test.com']"
    assert_contain 'not found'
  end

  test 'magic link request with email of different case should succeed when email is in the list of case insensitive keys' do
    create_user(email: 'Foo@Bar.com')

    request_magic_link do
      fill_in 'email', with: 'foo@bar.com'
    end

    assert_current_url '/users/sign_in'
    assert_contain 'You will receive an email with a magic link to sign in to your account in a few minutes.'
  end

  test 'user with valid magic link token should be able to sign in' do
    user = create_user
    request_magic_link
    sign_in_with_magic_link

    assert_current_url '/'
    assert_contain 'Signed in successfully.'
    assert warden.authenticated?(:user)
    assert_equal user.id, warden.user(:user).id
  end

  test 'magic link token should be consumed after a successful sign in' do
    user = create_user
    request_magic_link
    sign_in_with_magic_link

    assert warden.authenticated?(:user)
    assert_nil user.reload.magic_link_token
    assert_nil user.reload.magic_link_sent_at
  end

  test 'magic link should not be usable twice' do
    create_user
    request_magic_link
    sign_in_with_magic_link
    assert warden.authenticated?(:user)

    delete destroy_user_session_path
    assert_not warden.authenticated?(:user)

    sign_in_with_magic_link
    assert_not warden.authenticated?(:user)
    assert_contain 'Invalid or expired magic link. Please request a new one.'
  end

  test 'user with invalid magic link token should not be able to sign in' do
    create_user
    request_magic_link
    sign_in_with_magic_link('invalid_token')

    assert_not warden.authenticated?(:user)
    assert_contain 'Invalid or expired magic link. Please request a new one.'
  end

  test 'user with expired magic link token should not be able to sign in' do
    swap Devise, magic_link_within: 20.minutes do
      user = create_user
      request_magic_link
      user.reload.update_attribute(:magic_link_sent_at, 21.minutes.ago)

      sign_in_with_magic_link

      assert_not warden.authenticated?(:user)
      assert_contain 'Invalid or expired magic link. Please request a new one.'
    end
  end

  test 'user without a magic link token should not be able to visit the sign in endpoint' do
    get user_magic_link_path

    assert_response :redirect
    assert_redirected_to '/users/sign_in'
  end

  test 'magic link token should not authenticate outside the magic link endpoint' do
    create_user
    request_magic_link

    get root_path(magic_link_token: 'abcdef')

    assert_not warden.authenticated?(:user)
  end

  test 'locked user should not be able to sign in with a magic link' do
    create_user(locked: true)
    request_magic_link
    sign_in_with_magic_link

    assert_not warden.authenticated?(:user)
    assert_contain 'Your account is locked.'
  end

  test 'unconfirmed user should not be able to sign in with a magic link' do
    create_user(confirm: false)
    request_magic_link
    sign_in_with_magic_link

    assert_not warden.authenticated?(:user)
    assert_contain 'You have to confirm your email address before continuing.'
  end

  test 'magic link request with valid e-mail in JSON format should return empty and valid response' do
    create_user
    post user_magic_link_path(format: 'json'), params: { user: { email: 'user@test.com' } }
    assert_response :success
    assert_equal({}.to_json, response.body)
  end

  test 'magic link request with invalid e-mail in JSON format should return errors' do
    create_user
    post user_magic_link_path(format: 'json'), params: { user: { email: 'invalid.test@test.com' } }
    assert_response :unprocessable_entity
    assert_includes response.body, '{"errors":{'
  end

  test 'magic link request with invalid e-mail in JSON format should return empty and valid response in paranoid mode' do
    swap Devise, paranoid: true do
      create_user
      post user_magic_link_path(format: 'json'), params: { user: { email: 'invalid@test.com' } }
      assert_response :success
      assert_equal({}.to_json, response.body)
    end
  end

  test 'when in paranoid mode and with an invalid e-mail, requesting a magic link should not leak if the e-mail exists in the database' do
    swap Devise, paranoid: true do
      visit_new_magic_link_path
      fill_in 'email', with: 'arandomemail@test.com'
      click_button 'Send me a magic link'

      assert_not_contain 'not found'
      assert_contain 'If your email address exists in our database, you will receive an email with a magic link to sign in to your account in a few minutes.'
      assert_current_url '/users/sign_in'
    end
  end

  test 'when in paranoid mode and with a valid e-mail, requesting a magic link should display the same message' do
    swap Devise, paranoid: true do
      user = create_user
      visit_new_magic_link_path
      fill_in 'email', with: user.email
      click_button 'Send me a magic link'

      assert_contain 'If your email address exists in our database, you will receive an email with a magic link to sign in to your account in a few minutes.'
      assert_current_url '/users/sign_in'
    end
  end

  test 'user over the magic link request limit should see an error message' do
    user = create_user
    user.update_attribute(:magic_link_first_request_at, Time.now.utc)
    user.update_attribute(:magic_link_requests_count, User.magic_link_request_limit)

    request_magic_link

    assert_response :success
    assert_current_url '/users/magic_link'
    assert_contain 'Too many magic links were requested. You can request a new one in about 1 hour.'
    assert_equal User.magic_link_request_limit, user.reload.magic_link_requests_count
  end

  test 'user over the magic link request limit should be able to request again after the period expires' do
    user = create_user
    user.update_attribute(:magic_link_first_request_at, 61.minutes.ago)
    user.update_attribute(:magic_link_requests_count, User.magic_link_request_limit)

    request_magic_link

    assert_current_url '/users/sign_in'
    assert_contain 'You will receive an email with a magic link to sign in to your account in a few minutes.'
    assert_equal 1, user.reload.magic_link_requests_count
  end

  test 'when in paranoid mode, a request over the limit should not leak the rate limit error' do
    swap Devise, paranoid: true do
      user = create_user
      user.update_attribute(:magic_link_first_request_at, Time.now.utc)
      user.update_attribute(:magic_link_requests_count, User.magic_link_request_limit)

      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        request_magic_link
      end

      assert_not_contain 'Too many magic links were requested.'
      assert_contain 'If your email address exists in our database, you will receive an email with a magic link to sign in to your account in a few minutes.'
      assert_current_url '/users/sign_in'
    end
  end

  test 'magic link request over the limit in JSON format should return errors' do
    user = create_user
    user.update_attribute(:magic_link_first_request_at, Time.now.utc)
    user.update_attribute(:magic_link_requests_count, User.magic_link_request_limit)

    post user_magic_link_path(format: 'json'), params: { user: { email: 'user@test.com' } }
    assert_response :unprocessable_entity
    assert_includes response.body, 'Too many magic links were requested.'
  end

  test 'after signing in with a magic link, callback is triggered' do
    create_user
    request_magic_link

    User.any_instance.expects(:after_magic_link_authentication)
    sign_in_with_magic_link
  end
end
