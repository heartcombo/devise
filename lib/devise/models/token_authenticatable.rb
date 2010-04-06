require 'devise/strategies/token_authenticatable'

module Devise
  module Models
    # The TokenAuthenticatable module is responsible for generating an authentication token and
    # validating the authenticity of the same while signing in.
    #
    # This module only provides a few helpers to help you manage the token. Creating and resetting
    # the token is your responsibility.
    #
    # == Configuration:
    #
    # You can overwrite configuration values by setting in globally in Devise (+Devise.setup+),
    # using devise method, or overwriting the respective instance method.
    #
    # +token_authentication_key+ - Defines name of the authentication token params key. E.g. /users/sign_in?some_key=...
    #
    module TokenAuthenticatable
      extend ActiveSupport::Concern

      # Generate new authentication token (a.k.a. "single access token").
      def reset_authentication_token
        self.authentication_token = self.class.authentication_token
      end

      # Generate new authentication token and save the record.
      def reset_authentication_token!
        reset_authentication_token
        self.save(:validate => false)
      end

      # Generate authentication token unless already exists.
      def ensure_authentication_token
        self.reset_authentication_token if self.authentication_token.blank?
      end

      # Generate authentication token unless already exists and save the record.
      def ensure_authentication_token!
        self.reset_authentication_token! if self.authentication_token.blank?
      end

      # Hook called after token authentication.
      def after_token_authentication
      end

      module ClassMethods
        ::Devise::Models.config(self, :token_authentication_key)

        def find_for_token_authentication(conditions)
          conditions[:authentication_token] ||= conditions.delete(token_authentication_key)
          find_for_authentication(conditions)
        end

        def authentication_token
          ::Devise.friendly_token
        end
      end
    end
  end
end
