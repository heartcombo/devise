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
      # TODO Test me
      #
      def logout(*args)
        warden.raw_session.inspect  # Without this inspect here.  The session does not clear :|
        warden.logout(*args)
      end

      # TODO Test me
      def set_flash_message(key, kind, now=false)
        hash = now ? flash.now : flash
        hash[key] = I18n.t(:"#{resource_name}.#{kind}", :scope => [:devise, controller_name.to_sym], :default => kind)
      end
    end
  end
end
