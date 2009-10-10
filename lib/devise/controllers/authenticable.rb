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
      def authenticated?(*args)
        warden.authenticated?(*args)
      end
      alias_method :logged_in?, :authenticated?

      # Access the currently logged in user
      #
      def user(*args)
        warden.user(*args)
      end
      alias_method :current_user, :user

      def user=(user)
        warden.set_user user
      end
      alias_method :current_user=, :user=

      # Logout the current user
      #
      def logout(*args)
        warden.raw_session.inspect  # Without this inspect here.  The session does not clear :|
        warden.logout(*args)
      end

      # Verify authenticated user and redirect to sign in if no authentication is found
      #
      def authenticate!(*args)
        redirect_to new_session_path unless authenticated?
      end

      # Helper for use in before_filters where no authentication is required:
      # Example:
      #   before_filter :require_no_authentication, :only => :new
      #
      def require_no_authentication
        redirect_to root_path if authenticated?
      end
    end
  end
end
