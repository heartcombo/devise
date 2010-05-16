require 'test_helper'

class RememberMeTest < ActionController::IntegrationTest

  def create_user_and_remember(add_to_token='')
    Devise.remember_for = 1
    user = create_user
    user.remember_me!
    raw_cookie = User.serialize_into_cookie(user).tap { |a| a.last << add_to_token }
    cookies['remember_user_token'] = generate_signed_cookie(raw_cookie)
    user
  end

  def generate_signed_cookie(raw_cookie)
    request = ActionDispatch::TestRequest.new
    request.cookie_jar.signed['raw_cookie'] = raw_cookie
    request.cookie_jar['raw_cookie']
  end

  test 'do not remember the user if he has not checked remember me option' do
    user = sign_in_as_user
    assert_nil request.cookies["remember_user_cookie"]
    assert_nil user.reload.remember_token
  end

  test 'generate remember token after sign in' do
    user = sign_in_as_user :remember_me => true
    assert request.cookies["remember_user_token"]
    assert user.reload.remember_token
  end

  test 'generate remember token after sign in setting cookie domain' do
    # We test this by asserting the cookie is not sent after the redirect
    # since we changed the domain. This is the only difference with the
    # previous test.
    swap User, :cookie_domain => "omg.somewhere.com" do
      user = sign_in_as_user :remember_me => true
      assert_nil request.cookies["remember_user_token"]
    end
  end

  test 'remember the user before sign in' do
    user = create_user_and_remember
    get users_path
    assert_response :success
    assert warden.authenticated?(:user)
    assert warden.user(:user) == user
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

  test 'forget the user before sign out' do
    user = create_user_and_remember
    get users_path
    assert warden.authenticated?(:user)
    get destroy_user_session_path
    assert_not warden.authenticated?(:user)
    assert_nil user.reload.remember_token
  end

  test 'do not remember the user anymore after forget' do
    user = create_user_and_remember
    get users_path
    assert warden.authenticated?(:user)
    get destroy_user_session_path
    get users_path
    assert_not warden.authenticated?(:user)
  end
end
