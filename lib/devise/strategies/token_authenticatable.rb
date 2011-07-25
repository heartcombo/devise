require 'devise/strategies/base'

module Devise
  module Strategies
    # Strategy for signing in a user, based on a authenticatable token. This works for both params
    # and http. For the former, all you need to do is to pass the params in the URL:
    #
    #   http://myapp.example.com/?user_token=SECRET
    #
    # For HTTP, you can pass the token as username and blank password. Since some clients may require
    # a password, you can pass "X" as password and it will simply be ignored.
    class TokenAuthenticatable < Authenticatable
      def store?
        !mapping.to.stateless_token
      end

      def authenticate!
        resource = mapping.to.find_for_token_authentication(authentication_hash)

        if validate(resource)
          resource.after_token_authentication
          success!(resource)
        elsif !halted?
          fail(:invalid_token)
        end
      end

    private

      # TokenAuthenticatable request is valid for any controller and any verb.
      def valid_request?
        true
      end

      # Do not use remember_me behavior with token.
      def remember_me?
        false
      end

      # Try both scoped and non scoped keys.
      def params_auth_hash
        if params[scope].kind_of?(Hash) && params[scope].has_key?(authentication_keys.first)
          params[scope]
        else
          params
        end
      end

      # Overwrite authentication keys to use token_authentication_key.
      def authentication_keys
        @authentication_keys ||= [mapping.to.token_authentication_key]
      end
    end
  end
end

Warden::Strategies.add(:token_authenticatable, Devise::Strategies::TokenAuthenticatable)
