module Devise
  module Controllers

    # Some helpers taken from RailsWarden.
    module Authenticable

      def self.included(base)
        base.class_eval do
          helper_method :warden, :current_user, :signed_in?
        end
      end

      # The main accessor for the warden proxy instance
      #
      def warden
        request.env['warden']
      end

      # Proxy to the authenticated? method on warden
      #
      def authenticated?(scope=:default)
        warden.authenticated?(scope.to_sym)
      end
      alias_method :signed_in?, :authenticated?

      # Access the currently logged in user based on the scope
      #
      def current_user(scope=resource_name)
        warden.user(scope)
      end

      def current_user=(user)
        warden.set_user(user, :scope => resource_name)
      end

      # Logout the current user based on scope
      #
      def logout
        warden.raw_session.inspect  # Without this inspect here.  The session does not clear :|
        warden.logout(resource_name)
      end
    end
  end
end
