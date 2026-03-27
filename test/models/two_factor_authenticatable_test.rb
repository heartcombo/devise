# frozen_string_literal: true

require 'test_helper'

class TwoFactorAuthenticatableTest < ActiveSupport::TestCase
  test '.two_factor_modules returns the configured two_factor_methods' do
    klass = Class.new do
      extend Devise::Models::TwoFactorAuthenticatable::ClassMethods
    end
    klass.instance_variable_set(:@two_factor_methods, [:fake_method])

    assert_equal [:fake_method], klass.two_factor_modules
  end

  test '.two_factor_modules returns empty array when no methods configured' do
    klass = Class.new do
      extend Devise::Models::TwoFactorAuthenticatable::ClassMethods
    end

    assert_equal [], klass.two_factor_modules
  end

  test '#two_factor_enabled? returns true when any method reports enabled' do
    klass = Class.new do
      include Devise::Models::TwoFactorAuthenticatable
    end
    klass.instance_variable_set(:@two_factor_methods, [:fake_method])

    instance = klass.new
    instance.define_singleton_method(:fake_method_two_factor_enabled?) { true }

    assert instance.two_factor_enabled?
    assert_equal [:fake_method], instance.enabled_two_factors
  end

  test '#two_factor_enabled? returns false when no method reports enabled' do
    klass = Class.new do
      include Devise::Models::TwoFactorAuthenticatable
    end
    klass.instance_variable_set(:@two_factor_methods, [:fake_method])

    instance = klass.new
    instance.define_singleton_method(:fake_method_two_factor_enabled?) { false }

    assert_not instance.two_factor_enabled?
    assert_empty instance.enabled_two_factors
  end

  test '#enabled_two_factors returns only enabled methods' do
    klass = Class.new do
      include Devise::Models::TwoFactorAuthenticatable
    end
    klass.instance_variable_set(:@two_factor_methods, [:method_a, :method_b])

    instance = klass.new
    instance.define_singleton_method(:method_a_two_factor_enabled?) { true }
    instance.define_singleton_method(:method_b_two_factor_enabled?) { false }

    assert_equal [:method_a], instance.enabled_two_factors
  end

  test '.two_factor_methods= raises on unknown method' do
    klass = Class.new do
      extend Devise::Models::TwoFactorAuthenticatable::ClassMethods
    end

    assert_raises(RuntimeError, /Unknown two-factor method/) do
      klass.two_factor_methods = [:nonexistent]
    end
  end

  test '.two_factor_methods= includes model concern from registry' do
    # Register a fake method
    Devise.register_two_factor_method(:includable_test,
      model: 'devise/models/test_otp',
      strategy: :test_strategy)

    klass = Class.new do
      extend Devise::Models::TwoFactorAuthenticatable::ClassMethods

      # Stub include to track what gets included
      def self.included_modules_tracker
        @included_modules_tracker ||= []
      end

      def self.include(mod)
        included_modules_tracker << mod
        super
      end
    end

    klass.two_factor_methods = [:includable_test]
    assert_equal [:includable_test], Array(klass.instance_variable_get(:@two_factor_methods))
  ensure
    Devise.two_factor_method_configs.delete(:includable_test)
    Devise::STRATEGIES.delete(:includable_test)
  end
end
