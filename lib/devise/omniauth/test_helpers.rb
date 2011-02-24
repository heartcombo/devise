module Devise
  module OmniAuth
    module TestHelpers
      DEPRECATION_MESSAGE = "Faraday changed the way mocks work in a way incompatible to Devise. Luckily, Omniauth now supports a new test mode, please use it in your tests instead: https://github.com/intridea/omniauth/wiki/Integration-Testing"

      DeprecationError = Class.new(StandardError)

      def self.stub!(*args)
        raise DeprecationError, DEPRECATION_MESSAGE
      end

      def self.reset_stubs!(*args)
        raise DeprecationError, DEPRECATION_MESSAGE
      end

      def self.test_mode!
        warn DEPRECATION_MESSAGE
      end

      def self.short_circuit_authorizers!
        ::OmniAuth.config.test_mode = true
        warn DEPRECATION_MESSAGE
      end

      def self.unshort_circuit_authorizers!
        ::OmniAuth.config.test_mode = false
        warn DEPRECATION_MESSAGE
      end
    end
  end
end
