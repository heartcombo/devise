module Devise
  module Controllers

    # Some helpers taken from RailsWarden.
    module Authenticable

      def self.included(base)
        base.class_eval do
          helper_method :warden, :user, :logged_in?
#          helper_method :session_path, :session_url,
#                        :new_session_path, :new_session_url,
#                        :password_path, :password_url,
#                        :new_password_path, :new_password_url,
#                        :confirmation_path, :confirmation_url,
#                        :new_confirmation_path, :new_confirmation_url
        end
      end

      # The main accessor for the warden proxy instance
      #
      def warden
        request.env['warden']
      end

      # Proxy to the authenticated? method on warden
      #
      def authenticated?(scope=resource_name)
        warden.authenticated?(scope.to_sym)
      end
      alias_method :logged_in?, :authenticated?

      # Access the currently logged in user
      #
      def user
        warden.user(resource_name)
      end
      alias_method :current_user, :user

      def user=(user)
        warden.set_user(user, :scope => resource_name)
      end
      alias_method :current_user=, :user=

      # Logout the current user
      #
      def logout
        warden.raw_session.inspect  # Without this inspect here.  The session does not clear :|
        warden.logout(resource_name)
      end
    end
  end
end
