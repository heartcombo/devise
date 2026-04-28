# frozen_string_literal: true

require 'test_helper'

class TwoFactorStrategyTest < ActiveSupport::TestCase
  test 'TwoFactor strategy can be loaded' do
    assert defined?(Devise::Strategies::TwoFactor)
  end

  test 'TwoFactor base strategy is not valid without a pending session' do
    strategy = Devise::Strategies::TwoFactor.new(env_with_session)
    assert_not strategy.valid?
  end

  test 'verify_two_factor! raises NotImplementedError by default' do
    strategy = Devise::Strategies::TwoFactor.new(env_with_session)
    assert_raises(NotImplementedError) do
      strategy.verify_two_factor!(Object.new)
    end
  end

  private

  def env_with_session(session = {})
    { 'rack.session' => session }
  end
end
