require 'test_helper'

class AuthenticatableTest < ActiveSupport::TestCase
  test 'required_fields should be an empty array' do
    assert_equal Devise::Models::Validatable.required_fields(User), []
  end
end