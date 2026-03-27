# frozen_string_literal: true

require 'test_helper'

class TwoFactorStrategyTest < ActiveSupport::TestCase
  test 'TwoFactor strategy can be loaded' do
    assert defined?(Devise::Strategies::TwoFactor)
  end

  test 'TwoFactor base strategy is never valid' do
    strategy = Devise::Strategies::TwoFactor.new(nil)
    assert_equal false, strategy.valid?
  end

  test 'verify_two_factor! raises NotImplementedError by default' do
    strategy = Devise::Strategies::TwoFactor.new(nil)
    assert_raises(NotImplementedError) do
      strategy.verify_two_factor!(Object.new)
    end
  end
end
