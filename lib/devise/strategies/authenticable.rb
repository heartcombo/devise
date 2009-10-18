module Devise
  module Strategies
    # Default strategy for signing in a user, based on his email and password.
    # If no email and no password are present, no authentication is attempted.
    class Authenticable < Devise::Strategies::Base

      # Authenticate a user based on email and password params, returning to warden
      # success and the authenticated user if everything is okay. Otherwise redirect
      # to sign in page.
      def authenticate!
        if valid_attributes? && resource = mapping.to.authenticate(attributes)
          success!(resource)
        else
          store_location
          redirect!("/#{mapping.as}/#{mapping.path_names[:sign_in]}", :unauthenticated => true)
        end
      end

      # Find the attributes for the current mapping.
      def attributes
        @attributes ||= request.params[scope]
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
