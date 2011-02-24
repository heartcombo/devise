require 'test_helper'

class RememberMeTest < ActionController::IntegrationTest
  def create_user_and_remember(add_to_token='')
    user = create_user
    user.remember_me!
    raw_cookie = User.serialize_into_cookie(user).tap { |a| a.last << add_to_token }
    cookies['remember_user_token'] = generate_signed_cookie(raw_cookie)
    user
  end

  def create_admin_and_remember
    admin = create_admin
    admin.remember_me!
    raw_cookie = Admin.serialize_into_cookie(admin)
    cookies['remember_admin_token'] = generate_signed_cookie(raw_cookie)
    admin
  end

  def generate_signed_cookie(raw_cookie)
    request = ActionDispatch::TestRequest.new
    request.cookie_jar.signed['raw_cookie'] = raw_cookie
    request.cookie_jar['raw_cookie']
  end

  def signed_cookie(key)
    controller.send(:cookies).signed[key]
  end

  def cookie_expires(key)
    cookie  = response.headers["Set-Cookie"].split("\n").grep(/^#{key}/).first
    expires = cookie.split(";").map(&:strip).grep(/^expires=/).first
    Time.parse(expires).utc
  end

  test 'do not remember the user if he has not checked remember me option' do
    user = sign_in_as_user
    assert_nil request.cookies["remember_user_cookie"]
  end

  test 'generate remember token after sign in' do
    user = sign_in_as_user :remember_me => true
    assert request.cookies["remember_user_token"]
  end

  test 'generate remember token after sign in setting cookie options' do
    # We test this by asserting the cookie is not sent after the redirect
    # since we changed the domain. This is the only difference with the
    # previous test.
    swap Devise, :cookie_options => { :domain => "omg.somewhere.com" } do
      user = sign_in_as_user :remember_me => true
      assert_nil request.cookies["remember_user_token"]
    end
  end

  test 'generate remember token after sign in setting session options' do
    begin
      Rails.configuration.session_options[:domain] = "omg.somewhere.com"
      user = sign_in_as_user :remember_me => true
      assert_nil request.cookies["remember_user_token"]
    ensure
      Rails.configuration.session_options.delete(:domain)
    end
  end

  test 'remember the user before sign in' do
    user = create_user_and_remember
    get users_path
    assert_response :success
    assert warden.authenticated?(:user)
    assert warden.user(:user) == user
    assert_match /remember_user_token[^\n]*HttpOnly\n/, response.headers["Set-Cookie"], "Expected Set-Cookie header in response to set HttpOnly flag on remember_user_token cookie."
  end

  test 'cookies are destroyed on unverified requests' do
    swap ApplicationController, :allow_forgery_protection => true do
      user = create_user_and_remember
      get users_path
      assert warden.authenticated?(:user)
      post root_path, :authenticity_token => 'INVALID'
      assert_not warden.authenticated?(:user)
    end
  end

  test 'does not extend remember period through sign in' do
    swap Devise, :extend_remember_period => true, :remember_for => 1.year do
      user = create_user
      user.remember_me!

      user.remember_created_at = old = 10.days.ago
      user.save

      sign_in_as_user :remember_me => true
      user.reload

      assert warden.user(:user) == user
      assert_equal old.to_i, user.remember_created_at.to_i
    end
  end

  test 'if both extend_remember_period and remember_across_browsers are true, sends the same token with a new expire date' do
    swap Devise, :remember_across_browsers => true, :extend_remember_period => true, :remember_for => 1.year do
      admin = create_admin_and_remember
      token = admin.remember_token

      admin.remember_created_at = old = 10.minutes.ago
      admin.save!

      get root_path
      assert (cookie_expires("remember_admin_token") - 1.year) > (old + 5.minutes)
      assert_equal token, signed_cookie("remember_admin_token").last
    end
  end

  test 'if both extend_remember_period and remember_across_browsers are false, sends a new token with old expire date' do
    swap Devise, :remember_across_browsers => false, :extend_remember_period => false, :remember_for => 1.year do
      admin = create_admin_and_remember
      token = admin.remember_token

      admin.remember_created_at = old = 10.minutes.ago
      admin.save!

      get root_path
      assert (cookie_expires("remember_admin_token") - 1.year) < (old + 5.minutes)
      assert_not_equal token, signed_cookie("remember_admin_token").last
    end
  end

  test 'do not remember other scopes' do
    user = create_user_and_remember
    get root_path
    assert_response :success
    assert warden.authenticated?(:user)
    assert_not warden.authenticated?(:admin)
  end

  test 'do not remember with invalid token' do
    user = create_user_and_remember('add')
    get users_path
    assert_not warden.authenticated?(:user)
    assert_redirected_to new_user_session_path
  end

  test 'do not remember with expired token' do
    user = create_user_and_remember
    swap Devise, :remember_for => 0 do
      get users_path
      assert_not warden.authenticated?(:user)
      assert_redirected_to new_user_session_path
    end
  end

  test 'do not remember the user anymore after forget' do
    user = create_user_and_remember
    get users_path
    assert warden.authenticated?(:user)

    get destroy_user_session_path
    assert_not warden.authenticated?(:user)
    assert_nil warden.cookies['remember_user_token']

    get users_path
    assert_not warden.authenticated?(:user)
  end

  test 'do not remember the admin anymore after forget' do
    admin = create_admin_and_remember
    get root_path
    assert warden.authenticated?(:admin)

    get destroy_admin_session_path
    assert_not warden.authenticated?(:admin)
    assert_nil admin.reload.remember_token
    assert_nil warden.cookies['remember_admin_token']

    get root_path
    assert_not warden.authenticated?(:admin)
  end

  test 'changing user password expires remember me token' do
    user = create_user_and_remember
    user.password = "another_password"
    user.password_confirmation = "another_password"
    user.save!

    get users_path
    assert_not warden.authenticated?(:user)
  end
end
