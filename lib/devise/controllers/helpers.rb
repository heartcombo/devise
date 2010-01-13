module Devise
  module Controllers
    # Those helpers are convenience methods added to ApplicationController.
    module Helpers

      def self.included(base)
        base.class_eval do
          helper_method :warden, :signed_in?, :devise_controller?,
                        *Devise.mappings.keys.map { |m| [:"current_#{m}", :"#{m}_signed_in?"] }.flatten

          # Use devise default_url_options. We have to declare it here to overwrite
          # default definitions.
          def default_url_options(options=nil)
            Devise::Mapping.default_url_options
          end
        end
      end

      # The main accessor for the warden proxy instance
      def warden
        request.env['warden']
      end

      # Return true if it's a devise_controller. false to all controllers unless
      # the controllers defined inside devise. Useful if you want to apply a before
      # filter to all controller, except the ones in devise:
      #
      #   before_filter :my_filter, :unless => { |c| c.devise_controller? }
      def devise_controller?
        false
      end

      # Attempts to authenticate the given scope by running authentication hooks,
      # but does not redirect in case of failures.
      def authenticate(scope)
        warden.authenticate(:scope => scope)
      end

      # Attempts to authenticate the given scope by running authentication hooks,
      # redirecting in case of failures.
      def authenticate!(scope)
        warden.authenticate!(:scope => scope)
      end

      # Check if the given scope is signed in session, without running
      # authentication hooks.
      def signed_in?(scope)
        warden.authenticated?(scope)
      end

      # Sign in an user that already was authenticated. This helper is useful for logging
      # users in after sign up.
      #
      # Examples:
      #
      #   sign_in :user, @user    # sign_in(scope, resource)
      #   sign_in @user           # sign_in(resource)
      #
      def sign_in(resource_or_scope, resource=nil)
        scope    ||= Devise::Mapping.find_scope!(resource_or_scope)
        resource ||= resource_or_scope
        warden.set_user(resource, :scope => scope)
      end

      # Sign out a given user or scope. This helper is useful for signing out an user
      # after deleting accounts.
      #
      # Examples:
      #
      #   sign_out :user     # sign_out(scope)
      #   sign_out @user     # sign_out(resource)
      #
      def sign_out(resource_or_scope)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        warden.user(scope) # Without loading user here, before_logout hook is not called
        warden.raw_session.inspect # Without this inspect here. The session does not clear.
        warden.logout(scope)
      end

      # Returns and delete the url stored in the session for the given scope. Useful
      # for giving redirect backs after sign up:
      #
      # Example:
      #
      #   redirect_to stored_location_for(:user) || root_path
      #
      def stored_location_for(resource_or_scope)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        session.delete(:"#{scope}.return_to")
      end

      # The default url to be used after signing in. This is used by all Devise
      # controllers and you can overwrite it in your ApplicationController to
      # provide a custom hook for a custom resource.
      #
      # By default, it first tries to find a resource_root_path, otherwise it
      # uses the root path. For a user scope, you can define the default url in
      # the following way:
      #
      #   map.user_root '/users', :controller => 'users' # creates user_root_path
      #
      #   map.resources :users do |users|
      #     users.root # creates user_root_path
      #   end
      #
      # If none of these are defined, root_path is used.
      def after_sign_in_path_for(resource_or_scope)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        home_path = :"#{scope}_root_path"
        respond_to?(home_path, true) ? send(home_path) : root_path
      end

      # The default to be used after signing out. This is used by all Devise
      # controllers and you can overwrite it in your ApplicationController to
      # provide a custom hook for a custom resource.
      #
      # By default is the root_path.
      def after_sign_out_path_for(resource_or_scope)
        root_path
      end

      # Sign in an user and tries to redirect first to the stored location and
      # then to the url specified by after_sign_in_path_for.
      #
      # If just a symbol is given, consider that the user was already signed in
      # through other means and just perform the redirection.
      def sign_in_and_redirect(*args)
        sign_in(*args) unless args.size == 1 && args.first.is_a?(Symbol)
        redirect_to stored_location_for(args.first) || after_sign_in_path_for(args.first)
      end

      # Sign out an user and tries to redirect to the url specified by
      # after_sign_out_path_for.
      def sign_out_and_redirect(resource_or_scope)
        sign_out(resource_or_scope)
        redirect_to after_sign_out_path_for(resource_or_scope)
      end

      # Define authentication filters and accessor helpers based on mappings.
      # These filters should be used inside the controllers as before_filters,
      # so you can control the scope of the user who should be signed in to
      # access that specific controller/action.
      # Example:
      #
      #   Maps:
      #     User => :authenticatable
      #     Admin => :authenticatable
      #
      #   Generated methods:
      #     authenticate_user!  # Signs user in or redirect
      #     authenticate_admin! # Signs admin in or redirect
      #     user_signed_in?     # Checks whether there is an user signed in or not
      #     admin_signed_in?    # Checks whether there is an admin signed in or not
      #     current_user        # Current signed in user
      #     current_admin       # Currend signed in admin
      #     user_session        # Session data available only to the user scope
      #     admin_session       # Session data available only to the admin scope
      #
      #   Use:
      #     before_filter :authenticate_user!  # Tell devise to use :user map
      #     before_filter :authenticate_admin! # Tell devise to use :admin map
      #
      Devise.mappings.each_key do |mapping|
        class_eval <<-METHODS, __FILE__, __LINE__
          def authenticate_#{mapping}!
            warden.authenticate!(:scope => :#{mapping})
          end

          def #{mapping}_signed_in?
            warden.authenticated?(:#{mapping})
          end

          def current_#{mapping}
            @current_#{mapping} ||= warden.user(:#{mapping})
          end

          def #{mapping}_session
            warden.session(:#{mapping})
          end
        METHODS
      end

    end
  end
end
