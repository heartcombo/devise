# frozen_string_literal: true

# Test-only two-factor method for integration testing.
# Simulates a real 2FA extension with a simple OTP check.

require 'devise/models/two_factor_authenticatable'

module Devise
  module Models
    module TestOtp
      extend ActiveSupport::Concern

      def test_otp_two_factor_enabled?
        respond_to?(:otp_secret) && otp_secret.present?
      end
    end
  end
end

module Devise
  module Strategies
    class TestOtp < Devise::Strategies::TwoFactor
      def valid?
        super && params[:otp_attempt].present?
      end

      def verify_two_factor!(resource)
        unless resource.respond_to?(:otp_secret) && params[:otp_attempt] == resource.otp_secret
          fail!(:invalid_otp)
          return
        end
      end
    end
  end
end

Warden::Strategies.add(:test_otp, Devise::Strategies::TestOtp)

Devise.register_two_factor_method :test_otp,
  model: 'devise/models/test_otp',
  strategy: :test_otp
