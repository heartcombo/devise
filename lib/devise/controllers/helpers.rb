module Devise
  module Controllers
    # Those helpers are convenience methods added to ApplicationController.
    module Helpers
      extend ActiveSupport::Concern

      included do
        helper_method :warden, :signed_in?, :devise_controller?
      end

      module ClassMethods
        def log_process_action(payload)
          payload[:status] ||= 401 unless payload[:exception]
          super
        end
      end

      # Define authentication filters and accessor helpers based on mappings.
      # These filters should be used inside the controllers as before_filters,
      # so you can control the scope of the user who should be signed in to
      # access that specific controller/action.
      # Example:
      #
      #   Roles:
      #     User
      #     Admin
      #
      #   Generated methods:
      #     authenticate_user!  # Signs user in or redirect
      #     authenticate_admin! # Signs admin in or redirect
      #     user_signed_in?     # Checks whether there is a user signed in or not
      #     admin_signed_in?    # Checks whether there is an admin signed in or not
      #     current_user        # Current signed in user
      #     current_admin       # Current signed in admin
      #     user_session        # Session data available only to the user scope
      #     admin_session       # Session data available only to the admin scope
      #
      #   Use:
      #     before_filter :authenticate_user!  # Tell devise to use :user map
      #     before_filter :authenticate_admin! # Tell devise to use :admin map
      #
      def self.define_helpers(mapping) #:nodoc:
        mapping = mapping.name

        class_eval <<-METHODS, __FILE__, __LINE__ + 1
          def authenticate_#{mapping}!(opts={})
            opts[:scope] = :#{mapping}
            warden.authenticate!(opts) if !devise_controller? || opts.delete(:force)
          end

          def #{mapping}_signed_in?
            !!current_#{mapping}
          end

          def current_#{mapping}
            @current_#{mapping} ||= warden.authenticate(:scope => :#{mapping})
          end

          def #{mapping}_session
            current_#{mapping} && warden.session(:#{mapping})
          end
        METHODS

        ActiveSupport.on_load(:action_controller) do
          helper_method "current_#{mapping}", "#{mapping}_signed_in?", "#{mapping}_session"
        end
      end

      # The main accessor for the warden proxy instance
      def warden
        request.env['warden']
      end

      # Return true if it's a devise_controller. false to all controllers unless
      # the controllers defined inside devise. Useful if you want to apply a before
      # filter to all controllers, except the ones in devise:
      #
      #   before_filter :my_filter, :unless => :devise_controller?
      def devise_controller?
        is_a?(DeviseController)
      end

      # Setup a param sanitizer to filter parameters using strong_parameters. See
      # lib/devise/parameter_sanitizer.rb for more info. Override this
      # method in your application controller to use your own parameter sanitizer.
      def devise_parameter_sanitizer
        @devise_parameter_sanitizer ||= if defined?(ActionController::StrongParameters)
          Devise::ParameterSanitizer.new(resource_class, resource_name, params)
        else
          Devise::BaseSanitizer.new(resource_class, resource_name, params)
        end
      end

      # Tell warden that params authentication is allowed for that specific page.
      def allow_params_authentication!
        request.env["devise.allow_params_authentication"] = true
      end

      # Return true if the given scope is signed in session. If no scope given, return
      # true if any scope is signed in. Does not run authentication hooks.
      def signed_in?(scope=nil)
        [ scope || Devise.mappings.keys ].flatten.any? do |_scope|
          warden.authenticate?(:scope => _scope)
        end
      end

      # Sign in a user that already was authenticated. This helper is useful for logging
      # users in after sign up.
      #
      # All options given to sign_in is passed forward to the set_user method in warden.
      # The only exception is the :bypass option, which bypass warden callbacks and stores
      # the user straight in session. This option is useful in cases the user is already
      # signed in, but we want to refresh the credentials in session.
      #
      # Examples:
      #
      #   sign_in :user, @user                      # sign_in(scope, resource)
      #   sign_in @user                             # sign_in(resource)
      #   sign_in @user, :event => :authentication  # sign_in(resource, options)
      #   sign_in @user, :store => false            # sign_in(resource, options)
      #   sign_in @user, :bypass => true            # sign_in(resource, options)
      #
      def sign_in(resource_or_scope, *args)
        options  = args.extract_options!
        scope    = Devise::Mapping.find_scope!(resource_or_scope)
        resource = args.last || resource_or_scope

        expire_session_data_after_sign_in!

        if options[:bypass]
          warden.session_serializer.store(resource, scope)
        elsif warden.user(scope) == resource && !options.delete(:force)
          # Do nothing. User already signed in and we are not forcing it.
          true
        else
          warden.set_user(resource, options.merge!(:scope => scope))
        end
      end

      # Sign out a given user or scope. This helper is useful for signing out a user
      # after deleting accounts. Returns true if there was a logout and false if there
      # is no user logged in on the referred scope
      #
      # Examples:
      #
      #   sign_out :user     # sign_out(scope)
      #   sign_out @user     # sign_out(resource)
      #
      def sign_out(resource_or_scope=nil)
        return sign_out_all_scopes unless resource_or_scope
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        user = warden.user(:scope => scope, :run_callbacks => false) # If there is no user

        warden.raw_session.inspect # Without this inspect here. The session does not clear.
        warden.logout(scope)
        warden.clear_strategies_cache!(:scope => scope)
        instance_variable_set(:"@current_#{scope}", nil)

        !!user
      end

      # Sign out all active users or scopes. This helper is useful for signing out all roles
      # in one click. This signs out ALL scopes in warden. Returns true if there was at least one logout
      # and false if there was no user logged in on all scopes.
      def sign_out_all_scopes(lock=true)
        users = Devise.mappings.keys.map { |s| warden.user(:scope => s, :run_callbacks => false) }

        warden.raw_session.inspect
        warden.logout
        expire_devise_cached_variables!
        warden.clear_strategies_cache!
        warden.lock! if lock

        users.any?
      end

      # Returns and delete (if it's navigational format) the url stored in the session for
      # the given scope. Useful for giving redirect backs after sign up:
      #
      # Example:
      #
      #   redirect_to stored_location_for(:user) || root_path
      #
      def stored_location_for(resource_or_scope)
        scope = Devise::Mapping.find_scope!(resource_or_scope)

        if is_navigational_format?
          session.delete("#{scope}_return_to")
        else
          session["#{scope}_return_to"]
        end
      end

      # The scope root url to be used when he's signed in. By default, it first
      # tries to find a resource_root_path, otherwise it uses the root_path.
      def signed_in_root_path(resource_or_scope)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        home_path = "#{scope}_root_path"
        if respond_to?(home_path, true)
          send(home_path)
        elsif respond_to?(:root_path)
          root_path
        else
          "/"
        end
      end

      # The default url to be used after signing in. This is used by all Devise
      # controllers and you can overwrite it in your ApplicationController to
      # provide a custom hook for a custom resource.
      #
      # By default, it first tries to find a valid resource_return_to key in the
      # session, then it fallbacks to resource_root_path, otherwise it uses the
      # root path. For a user scope, you can define the default url in
      # the following way:
      #
      #   map.user_root '/users', :controller => 'users' # creates user_root_path
      #
      #   map.namespace :user do |user|
      #     user.root :controller => 'users' # creates user_root_path
      #   end
      #
      # If the resource root path is not defined, root_path is used. However,
      # if this default is not enough, you can customize it, for example:
      #
      #   def after_sign_in_path_for(resource)
      #     stored_location_for(resource) ||
      #       if resource.is_a?(User) && resource.can_publish?
      #         publisher_url
      #       else
      #         super
      #       end
      #   end
      #
      def after_sign_in_path_for(resource_or_scope)
        stored_location_for(resource_or_scope) || signed_in_root_path(resource_or_scope)
      end

      # Method used by sessions controller to sign out a user. You can overwrite
      # it in your ApplicationController to provide a custom hook for a custom
      # scope. Notice that differently from +after_sign_in_path_for+ this method
      # receives a symbol with the scope, and not the resource.
      #
      # By default it is the root_path.
      def after_sign_out_path_for(resource_or_scope)
        respond_to?(:root_path) ? root_path : "/"
      end

      # Sign in a user and tries to redirect first to the stored location and
      # then to the url specified by after_sign_in_path_for. It accepts the same
      # parameters as the sign_in method.
      def sign_in_and_redirect(resource_or_scope, *args)
        options  = args.extract_options!
        scope    = Devise::Mapping.find_scope!(resource_or_scope)
        resource = args.last || resource_or_scope
        sign_in(scope, resource, options)
        redirect_to after_sign_in_path_for(resource)
      end

      def expire_session_data_after_sign_in!
        session.keys.grep(/^devise\./).each { |k| session.delete(k) }
      end

      # Sign out a user and tries to redirect to the url specified by
      # after_sign_out_path_for.
      def sign_out_and_redirect(resource_or_scope)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        redirect_path = after_sign_out_path_for(scope)
        Devise.sign_out_all_scopes ? sign_out : sign_out(scope)
        redirect_to redirect_path
      end

      # Overwrite Rails' handle unverified request to sign out all scopes,
      # clear run strategies and remove cached variables.
      def handle_unverified_request
        sign_out_all_scopes(false)
        request.env["devise.skip_storage"] = true
        expire_devise_cached_variables!
        super # call the default behaviour which resets the session
      end

      def request_format
        @request_format ||= request.format.try(:ref)
      end

      def is_navigational_format?
        Devise.navigational_formats.include?(request_format)
      end

      # Overwrite Rails' form authenticity token to allow for independent
      # authentication scopes
      def form_authenticity_token
        session_scope = warden.authenticated? ? warden.session : warden.request.session
        session_scope[:_csrf_token] ||= SecureRandom.base64(32)
      end

      private

      def expire_devise_cached_variables!
        Devise.mappings.each { |_,m| instance_variable_set("@current_#{m.name}", nil) }
      end
    end
  end
end
