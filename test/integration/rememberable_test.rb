require 'test/test_helper'

class RememberMeTest < ActionController::IntegrationTest

  def create_user_and_remember(add_to_token='')
    Devise.remember_for = 1
    user = create_user
    user.remember_me!
    cookies['remember_user_token'] = User.serialize_into_cookie(user) + add_to_token
    user
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
    assert_response :success
    assert_not warden.authenticated?(:user)
  end

  test 'do not remember with token expired' do
    user = create_user_and_remember
    Devise.remember_for = 0
    get users_path
    assert_response :success
    assert_not warden.authenticated?(:user)
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
