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
    if DEVISE_ORM == :mongoid
      raise 'There is an incompatibility between Devise and Mongoid'  << 
            ' that makes this test break. For more information, check' <<
            ' this issue: https://github.com/mongoid/mongoid/issues/725'
    end

    user = create_user
    user.ensure_authentication_token!
    user.confirm!
    authenticated_user = User.find_for_token_authentication(:auth_token => user.authentication_token.reverse)
    assert_nil authenticated_user
  end

end
