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

  test 'authenticates with a pending sign-in stored for its scope' do
    user = create_user_with_two_factor
    strategy = test_otp_strategy("devise.two_factor.user_with_two_factor" => pending_sign_in(user, purpose: :user_with_two_factor))

    strategy.authenticate!
    assert_equal :success, strategy.result
    assert_equal user, strategy.user
  end

  test 'does not authenticate with a pending sign-in stored for another scope' do
    user = create_user_with_two_factor
    strategy = test_otp_strategy("devise.two_factor.user_with_two_factor" => pending_sign_in(user, purpose: :admin))

    strategy.authenticate!
    assert_equal :failure, strategy.result
    assert_equal :two_factor_session_expired, strategy.message
  end

  test 'does not authenticate with a pending sign-in whose data was swapped for another user' do
    user = create_user_with_two_factor
    other_user = create_user_with_two_factor
    _, digest = pending_sign_in(user, purpose: :user_with_two_factor).split("--")
    other_data, _ = pending_sign_in(other_user, purpose: :user_with_two_factor).split("--")
    strategy = test_otp_strategy("devise.two_factor.user_with_two_factor" => "#{other_data}--#{digest}")

    strategy.authenticate!
    assert_equal :failure, strategy.result
    assert_equal :two_factor_session_expired, strategy.message
  end

  test 'clears a pending sign-in stored for another scope' do
    user = create_user_with_two_factor
    session = { "devise.two_factor.user_with_two_factor" => pending_sign_in(user, purpose: :admin) }
    strategy = test_otp_strategy(session)

    strategy.authenticate!
    assert_not session.key?("devise.two_factor.user_with_two_factor")
    assert_not strategy.valid?
  end

  private

  def env_with_session(session = {})
    { 'rack.session' => session }
  end

  def test_otp_strategy(session)
    env = Rack::MockRequest.env_for("/?otp_attempt=123456").merge('rack.session' => session)
    Devise::Strategies::TestOtp.new(env, :user_with_two_factor)
  end

  def pending_sign_in(user, purpose:)
    Rails.application.message_verifier("devise.two_factor").generate(
      { "record" => UserWithTwoFactor.serialize_into_session(user), "remember_me" => false },
      purpose: purpose
    )
  end

  def create_user_with_two_factor
    UserWithTwoFactor.create!(valid_attributes(otp_secret: '123456'))
  end
end
