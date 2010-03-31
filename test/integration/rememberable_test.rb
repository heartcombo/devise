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
    request = ActionDispatch::Request.new({})
    request.cookie_jar.signed['raw_cookie'] = raw_cookie
    request.cookie_jar['raw_cookie']
  end

  test 'do not remember the user if he has not checked remember me option' do
    user = sign_in_as_user
    assert_nil user.reload.remember_token
  end

  test 'generate remember token after sign in' do
    user = sign_in_as_user :remember_me => true
    assert_not_nil user.reload.remember_token
  end

  test 'remember the user before sign in' do
    user = create_user_and_remember
    get users_path
    assert_response :success
    assert warden.authenticated?(:user)
    assert warden.user(:user) == user
  end

  test 'does not remember other scopes' do
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
    assert_redirected_to new_user_session_path(:unauthenticated => true)
  end

  test 'do not remember with token expired' do
    user = create_user_and_remember
    swap Devise, :remember_for => 0 do
      get users_path
      assert_not warden.authenticated?(:user)
      assert_redirected_to new_user_session_path(:unauthenticated => true)
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
