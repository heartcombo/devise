# frozen_string_literal: true

require 'test_helper'

class TwoFactorAuthenticatableTest < ActiveSupport::TestCase
  test '.two_factor_modules returns the configured two_factor_methods' do
    assert_equal [:test_otp], UserWithTwoFactor.two_factor_modules
  end

  test '#two_factor_enabled? returns true when any method reports enabled' do
    user = new_user_with_two_factor
    user.stubs(:test_otp_two_factor_enabled?).returns(true)
    assert user.two_factor_enabled?
    assert_equal [:test_otp], user.enabled_two_factors
  end

  test '#two_factor_enabled? returns false when no method reports enabled' do
    user = new_user_with_two_factor
    user.stubs(:test_otp_two_factor_enabled?).returns(false)
    assert_not user.two_factor_enabled?
    assert_empty user.enabled_two_factors
  end

  test '.two_factor_methods= raises on unknown method' do
    klass = Class.new do
      extend Devise::Models::TwoFactorAuthenticatable::ClassMethods
    end

    assert_raises(RuntimeError, /Unknown two-factor method/) do
      klass.two_factor_methods = [:nonexistent]
    end
  end

  private

  def new_user_with_two_factor(attributes = {})
    UserWithTwoFactor.new(valid_attributes(attributes))
  end
end
