require 'devise/strategies/token_authenticatable'

module Devise
  module Models
    # Token Authenticatable Module, responsible for generate authentication token and validating
    # authenticity of a user while signing in using an authentication token (say follows an URL).
    #
    # == Configuration:
    #
    # You can overwrite configuration values by setting in globally in Devise (+Devise.setup+),
    # using devise method, or overwriting the respective instance method.
    #
    # +token_authentication_key+ - Defines name of the authentication token params key. E.g. /users/sign_in?some_key=...
    #
    # == Examples:
    #
    #    User.authenticate_with_token(:auth_token => '123456789')           # returns authenticated user or nil
    #    User.find(1).valid_authentication_token?('rI1t6PKQ8yP7VetgwdybB')  # returns true/false
    #
    module TokenAuthenticatable
      extend  ActiveSupport::Concern
      include Devise::Models::Authenticatable

      included do
        before_save :ensure_authentication_token
      end

      # Generate new authentication token (a.k.a. "single access token").
      def reset_authentication_token
        self.authentication_token = self.class.authentication_token
      end

      # Generate new authentication token and save the record.
      def reset_authentication_token!
        reset_authentication_token
        self.save
      end

      # Generate authentication token unless already exists.
      def ensure_authentication_token
        self.reset_authentication_token if self.authentication_token.blank?
      end

      # Generate authentication token unless already exists and save the record.
      def ensure_authentication_token!
        self.reset_authentication_token! if self.authentication_token.blank?
      end

      module ClassMethods
        ::Devise::Models.config(self, :token_authentication_key)

        # Authenticate a user based on authentication token.
        def authenticate_with_token(attributes)
          token = attributes[self.token_authentication_key]
          self.find_for_token_authentication(token)
        end

        def authentication_token
          ::Devise.friendly_token
        end

      protected

        # Find first record based on conditions given (ie by the sign in form).
        # Overwrite to add customized conditions, create a join, or maybe use a
        # namedscope to filter records while authenticating.
        #
        # == Example:
        #
        #   def self.find_for_token_authentication(token, conditions = {})
        #     conditions = {:active => true}
        #     super
        #   end
        #
        def find_for_token_authentication(token)
          self.find(:first, :conditions => { :authentication_token => token})
        end
      end
    end
  end
end
