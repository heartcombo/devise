module Devise
  module Strategies
    # Default strategy for signing in a user, based on his email and password.
    # Redirects to sign_in page if it's not authenticated
    class Authenticatable < Warden::Strategies::Base
      include Devise::Strategies::Base

      # Authenticate a user based on email and password params, returning to warden
      # success and the authenticated user if everything is okay. Otherwise redirect
      # to sign in page.
      #
      # Please notice the semantic difference between calling fail! and throw :warden.
      # The first does not perform any action when calling authenticate, just
      # when authenticate! is invoked. The second always perform the action.
      def authenticate!
        if valid_attributes? && resource = mapping.to.authenticate(attributes)
          success!(resource)
        else
          store_location
          fail!(:unauthenticated)
        end
      end

      private

        # Find the attributes for the current mapping.
        def attributes
          @attributes ||= params[scope]
        end

        # Check for the right keys.
        def valid_attributes?
          attributes && attributes[:email].present? && attributes[:password].present?
        end

        # Stores requested uri to redirect the user after signing in. We cannot use
        # scoped session provided by warden here, since the user is not authenticated
        # yet, but we still need to store the uri based on scope, so different scopes
        # would never use the same uri to redirect.
        def store_location
          session[:"#{mapping.name}.return_to"] = request.request_uri if request.get?
        end
    end
  end
end

Warden::Strategies.add(:authenticatable, Devise::Strategies::Authenticatable)
