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

    # Simulates a first-factor magic link strategy from an extension. Unlike
    # the core strategies, it does not wait for the sessions controller to
    # allow params authentication, so it is valid on any request with a token.
    class TestMagicLink < Devise::Strategies::Base
      def self.token_for(resource)
        Rails.application.message_verifier(:test_magic_link).generate(resource.email)
      end

      def valid?
        params[:magic_link_token].present?
      end

      def authenticate!
        email = Rails.application.message_verifier(:test_magic_link).verified(params[:magic_link_token])
        resource = email && mapping.to.find_for_authentication(email: email)
        resource ? success!(resource) : fail!(:invalid_token)
      end
    end
  end
end

Warden::Strategies.add(:test_otp, Devise::Strategies::TestOtp)
Warden::Strategies.add(:test_magic_link, Devise::Strategies::TestMagicLink)

Devise.register_two_factor_method :test_otp,
  model: 'devise/models/test_otp',
  strategy: :test_otp

Devise.warden do |warden_config|
  warden_config.default_strategies(scope: :user_with_two_factor).unshift :test_magic_link
end
