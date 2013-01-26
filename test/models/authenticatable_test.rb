require 'test_helper'

class AuthenticatableTest < ActiveSupport::TestCase
  test 'find_first_by_auth_conditions allows custom filtering parameters' do
    user = User.create!(email: "example@example.com", password: "123456")
    assert_equal User.find_first_by_auth_conditions({ email: "example@example.com" }), user
    assert_equal User.find_first_by_auth_conditions({ email: "example@example.com" }, id: user.id + 1), nil
  end
end
