require 'devise/strategies/base'

module Devise
  module Strategies
    # Strategy for signing in a user, based on a authenticatable token. This works for both params
    # and http. For the former, all you need to do is to pass the params in the URL:
    #
    #   http://myapp.example.com/?user_token=SECRET
    #
    # For HTTP, you can pass the token as username. Since some clients may require a password,
    # you can pass anything and it will simply be ignored.
    class TokenAuthenticatable < Authenticatable
      def authenticate!
        if resource = mapping.to.authenticate_with_token(authentication_hash)
          success!(resource)
        else
          fail(:invalid_token)
        end
      end

    private

      # TokenAuthenticatable params can be given to any controller.
      def valid_controller?
        true
      end

      # Do not use remember_me behavir with token.
      def remember_me?
        false
      end

      # Try both scoped and non scoped keys.
      def params_auth_hash
        params[scope] || params
      end

      # Overwrite authentication keys to use token_authentication_key.
      def authentication_keys
        @authentication_keys ||= [mapping.to.token_authentication_key]
      end
    end
  end
end

Warden::Strategies.add(:token_authenticatable, Devise::Strategies::TokenAuthenticatable)
