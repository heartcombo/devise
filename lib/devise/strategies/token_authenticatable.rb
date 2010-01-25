require 'devise/strategies/base'

module Devise
  module Strategies
    # Strategy for signing in a user, based on a authenticatable token.
    # Redirects to sign_in page if it's not authenticated.
    class TokenAuthenticatable < Base
      def valid?
        super && authentication_token(scope).present?
      end

      # Authenticate a user based on authenticatable token params, returning to warden
      # success and the authenticated user if everything is okay. Otherwise redirect
      # to sign in page.
      def authenticate!
        if resource = mapping.to.authenticate_with_token(params[scope] || params)
          success!(resource)
        else
          fail!(:invalid_token)
        end
      end

      private

        # Detect authentication token in params: scoped or not.
        def authentication_token(scope)
          if params[scope]
            params[scope][::Devise.authentication_token_param_key]
          else
            params[::Devise.authentication_token_param_key]
          end
        end

    end
  end
end

Warden::Strategies.add(:token_authenticatable, Devise::Strategies::TokenAuthenticatable)
