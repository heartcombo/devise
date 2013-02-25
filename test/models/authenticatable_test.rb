require 'test_helper'

class AuthenticatableTest < ActiveSupport::TestCase
  test 'required_fields should be an empty array' do
    assert_equal Devise::Models::Validatable.required_fields(User), []
  end

  test 'find_first_by_auth_conditions allows custom filtering parameters' do
    user = User.create!(:email => "example@example.com", :password => "123456", :password_confirmation => "123456")
    assert_equal User.find_first_by_auth_conditions({ :email => "example@example.com" }), user
    assert_nil User.find_first_by_auth_conditions({ :email => "example@example.com" }, :id => user.id.to_s.next)
  end
end
