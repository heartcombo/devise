require "uri"

module Devise
  module Controllers
    # Provide the ability to store a location.
    # Used to redirect back to a desired path after sign in.
    # Included by default in all controllers.
    module StoreLocation
      # Storing an excessively large location can cause a CookieOverflow error
      # if the app is using cookies for session storage
      MAX_LOCATION_SIZE = 2048

      # Returns and delete (if it's navigational format) the url stored in the session for
      # the given scope. Useful for giving redirect backs after sign up:
      #
      # Example:
      #
      #   redirect_to stored_location_for(:user) || root_path
      #
      def stored_location_for(resource_or_scope)
        session_key = stored_location_key_for(resource_or_scope)

        if is_navigational_format?
          session.delete(session_key)
        else
          session[session_key]
        end
      end

      # Stores the provided location to redirect the user after signing in.
      # Useful in combination with the `stored_location_for` helper.
      #
      # Example:
      #
      #   store_location_for(:user, dashboard_path)
      #   redirect_to user_omniauth_authorize_path(:facebook)
      #
      def store_location_for(resource_or_scope, location)
        return if location && location.size > MAX_LOCATION_SIZE
        session_key = stored_location_key_for(resource_or_scope)
        uri = parse_uri(location)
        if uri
          path = [uri.path.sub(/\A\/+/, '/'), uri.query].compact.join('?')
          path = [path, uri.fragment].compact.join('#')
          session[session_key] = path
        end
      end

      private

      def parse_uri(location)
        location && URI.parse(location)
      rescue URI::InvalidURIError
        nil
      end

      def stored_location_key_for(resource_or_scope)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        "#{scope}_return_to"
      end
    end
  end
end
