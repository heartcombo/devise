require 'devise/strategies/token_authenticatable'
require 'devise/hooks/token_authenticatable'

module Devise
  module Models
    # Token Authenticatable Module, responsible for generate authentication token and validating
    # authenticity of a user while signing in using a authentication token (say follows an URL).
    #
    # == Configuration:
    #
    # You can overwrite configuration values by setting in globally in Devise (+Devise.setup+),
    # using devise method, or overwriting the respective instance method.
    #
    # +authentication_token_param_key+ - Defines name of the authentication token params key. E.g. /users/sign_in?some_key=...
    #
    # +reset_authentication_token_on+ - Defines which callback hooks that should trigger a authentication token reset.
    #
    # == Examples:
    #
    #    User.authenticate_with_token(:auth_token => '123456789')           # returns authenticated user or nil
    #    User.find(1).valid_authentication_token?('rI1t6PKQ8yP7VetgwdybB')  # returns true/false
    #
    module TokenAuthenticatable
      def self.included(base)
        base.class_eval do
          extend ClassMethods

          before_save :ensure_authentication_token!
        end
      end

      # Generate authentication token unless already exists.
      #
      def ensure_authentication_token!
        self.reset_authentication_token!(false) if self.authentication_token.blank?
      end

      # Generate new authentication token (a.k.a. "single access token").
      #
      def reset_authentication_token!(do_save = true)
        self.authentication_token = self.class.authentication_token
        self.save if do_save
      end

      # Verifies whether an +incoming_authentication_token+ (i.e. from single access URL)
      # is the user authentication token.
      #
      def valid_authentication_token?(incoming_auth_token)
        incoming_auth_token.present? && incoming_auth_token == self.authentication_token
      end

      module ClassMethods

        ::Devise::Models.config(self, :authentication_token_param_key, :reset_authentication_token_on)

        # Authenticate a user based on authentication token.
        #
        def authenticate_with_token(attributes = {})
          token = attributes[::Devise.authentication_token_param_key]
          resource = self.find_for_token_authentication(token)
          resource if resource.try(:valid_authentication_token?, token)
        end

        def authentication_token
          ::Devise.friendly_token
        end

        protected

          # Find first record based on conditions given (ie by the sign in form).
          # Overwrite to add customized conditions, create a join, or maybe use a
          # namedscope to filter records while authenticating.
          # Example:
          #
          #   def self.find_for_token_authentication(token, conditions = {})
          #     conditions = {:active => true}
          #     self.find_by_authentication_token(token, :conditions => conditions)
          #   end
          #
          def find_for_token_authentication(token, conditions = {})
            self.find_by_authentication_token(token, :conditions => conditions)
          end

      end
    end
  end
end
