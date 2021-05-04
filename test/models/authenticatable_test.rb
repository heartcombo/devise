# frozen_string_literal: true

require 'test_helper'

class AuthenticatableTest < ActiveSupport::TestCase
  test 'required_fields should be an empty array' do
    assert_equal [], Devise::Models::Validatable.required_fields(User)
  end

  test 'find_first_by_auth_conditions allows custom filtering parameters' do
    user = User.create!(email: "example@example.com", password: "1234567")
    assert_equal user, User.find_first_by_auth_conditions({ email: "example@example.com" })
    assert_nil User.find_first_by_auth_conditions({ email: "example@example.com" }, id: user.id.to_s.next)
  end

  # assumes default configuration of
  # config.case_insensitive_keys = [:email]
  # config.strip_whitespace_keys = [:email]
  test 'find_or_initialize_with_errors uses parameter filter on find' do
    user = User.create!(email: "example@example.com", password: "1234567")
    assert_equal user, User.find_or_initialize_with_errors([:email], { email: " EXAMPLE@example.com " })
  end

  # assumes default configuration of
  # config.case_insensitive_keys = [:email]
  # config.strip_whitespace_keys = [:email]
  test 'find_or_initialize_with_errors uses parameter filter on initialize' do
    assert_equal "example@example.com", User.find_or_initialize_with_errors([:email], { email: " EXAMPLE@example.com " }).email
  end

  test 'find_or_initialize_with_errors adds blank error' do
    user_with_error = User.find_or_initialize_with_errors([:email], { email: "" })
    assert_equal ["Email can't be blank"], user_with_error.errors.full_messages_for(:email)
  end

  test 'find_or_initialize_with_errors adds invalid error' do
    user_with_error = User.find_or_initialize_with_errors([:email], { email: "example@example.com" })
    assert_equal ["Email is invalid"], user_with_error.errors.full_messages_for(:email)
  end

  if defined?(ActionController::Parameters)
    test 'does not passes an ActionController::Parameters to find_first_by_auth_conditions through find_or_initialize_with_errors' do
      user = create_user(email: 'example@example.com')
      attributes = ActionController::Parameters.new(email: 'example@example.com')

      User.expects(:find_first_by_auth_conditions).with('email' => 'example@example.com').returns(user)
      User.find_or_initialize_with_errors([:email], attributes)
    end
  end
end
