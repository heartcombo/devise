require 'test_helper'

class TokenAuthenticatableTest < ActiveSupport::TestCase

  test 'should generate friendly authentication token on create' do
    User.expects(:authentication_token).returns(VALID_AUTHENTICATION_TOKEN)
    user = create_user
    assert_present user.authentication_token
    assert_equal VALID_AUTHENTICATION_TOKEN, user.authentication_token
  end

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
    User.expects(:authentication_token).returns(VALID_AUTHENTICATION_TOKEN)
    user = create_user
    user.confirm!
    authenticated_user = User.authenticate_with_token(:auth_token => user.authentication_token)
    assert_equal authenticated_user, user
  end

  test 'should return nil when authenticating an invalid user by authentication token' do
    User.expects(:authentication_token).returns(VALID_AUTHENTICATION_TOKEN)
    user = create_user
    user.confirm!
    authenticated_user = User.authenticate_with_token(:auth_token => user.authentication_token.reverse)
    assert_nil authenticated_user
  end

end