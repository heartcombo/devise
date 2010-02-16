require 'test/test_helper'

class HttpAuthenticatableTest < ActiveSupport::TestCase
  test 'should authenticate a valid user with email and password and return it' do
    user = create_user
    user.confirm!

    authenticated_user = User.authenticate_with_http(user.email, user.password)
    assert_equal authenticated_user, user
  end

  test 'should return nil when authenticating an invalid user by email' do
    user = create_user
    user.confirm!

    authenticated_user = User.authenticate_with_http('another.email@email.com', user.password)
    assert_nil authenticated_user
  end
end
