require 'test_helper'

class TokenAuthenticatableTest < ActiveSupport::TestCase

  test 'should reset authentication token' do
    user = new_user
    user.reset_authentication_token
    previous_token = user.authentication_token
    user.reset_authentication_token
    assert_not_equal previous_token, user.authentication_token
  end

  test 'should ensure authentication token' do
    user = new_user
    user.ensure_authentication_token
    previous_token = user.authentication_token
    user.ensure_authentication_token
    assert_equal previous_token, user.authentication_token
  end

  test 'should authenticate a valid user with authentication token and return it' do
    user = create_user
    user.ensure_authentication_token!
    user.confirm!
    authenticated_user = User.find_for_token_authentication(:auth_token => user.authentication_token)
    assert_equal authenticated_user, user
  end

  test 'should return nil when authenticating an invalid user by authentication token' do
    user = create_user
    user.ensure_authentication_token!
    user.confirm!
    authenticated_user = User.find_for_token_authentication(:auth_token => user.authentication_token.reverse)
    assert_nil authenticated_user
  end

  test 'should not be subject to injection' do
    user1 = create_user
    user1.ensure_authentication_token!
    user1.confirm!

    user2 = create_user
    user2.ensure_authentication_token!
    user2.confirm!

    user = User.find_for_token_authentication(:auth_token => {'$ne' => user1.authentication_token})
    assert_nil user
  end

  test 'required_fields should contain the fields that Devise uses' do
    assert_equal Devise::Models::TokenAuthenticatable.required_fields(User).sort, [
      :authentication_token
    ]
  end
end
