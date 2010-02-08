module Devise
  module Controllers
    # Those helpers are used only inside Devise controllers and should not be
    # included in ApplicationController since they all depend on the url being
    # accessed.
    module InternalHelpers #:nodoc:

      def self.included(base)
        base.class_eval do
          extend ScopedViews
          unloadable

          helper_method :resource, :scope_name, :resource_name, :resource_class, :devise_mapping, :devise_controller?
          hide_action   :resource, :scope_name, :resource_name, :resource_class, :devise_mapping, :devise_controller?

          skip_before_filter *Devise.mappings.keys.map { |m| :"authenticate_#{m}!" }
          before_filter :is_devise_resource?
        end
      end

      module ScopedViews
        def scoped_views
          defined?(@scoped_views) ? @scoped_views : Devise.scoped_views
        end

        def scoped_views=(value)
          @scoped_views = value
        end
      end

      # Gets the actual resource stored in the instance variable
      def resource
        instance_variable_get(:"@#{resource_name}")
      end

      # Proxy to devise map name
      def resource_name
        devise_mapping.name
      end
      alias :scope_name :resource_name

      # Proxy to devise map class
      def resource_class
        devise_mapping.to
      end

      # Attempt to find the mapped route for devise based on request path
      def devise_mapping
        @devise_mapping ||= begin
          mapping   = Devise::Mapping.find_by_path(request.path)
          mapping ||= Devise.mappings[Devise.default_scope] if Devise.use_default_scope
          mapping
        end
      end

      # Overwrites devise_controller? to return true
      def devise_controller?
        true
      end

    protected

      # Checks whether it's a devise mapped resource or not.
      def is_devise_resource? #:nodoc:
        raise ActionController::UnknownAction unless devise_mapping && devise_mapping.allows?(controller_name)
      end

      # Sets the resource creating an instance variable
      def resource=(new_resource)
        instance_variable_set(:"@#{resource_name}", new_resource)
      end

      # Build a devise resource without setting password and password confirmation fields.
      def build_resource
        self.resource ||= begin
          attributes = params[resource_name].try(:except, :password, :password_confirmation)
          resource_class.new(attributes || {})
        end
      end

      # Helper for use in before_filters where no authentication is required.
      #
      # Example:
      #   before_filter :require_no_authentication, :only => :new
      def require_no_authentication
        redirect_to after_sign_in_path_for(resource_name) if warden.authenticated?(resource_name)
      end

      # Sets the flash message with :key, using I18n. By default you are able
      # to setup your messages using specific resource scope, and if no one is
      # found we look to default scope.
      # Example (i18n locale file):
      #
      #   en:
      #     devise:
      #       passwords:
      #         #default_scope_messages - only if resource_scope is not found
      #         user:
      #           #resource_scope_messages
      #
      # Please refer to README or en.yml locale file to check what messages are
      # available.
      def set_flash_message(key, kind, now=false)
        flash_hash = now ? flash.now : flash
        flash_hash[key] = I18n.t(:"#{resource_name}.#{kind}",
                            :scope => [:devise, controller_name.to_sym], :default => kind)
      end

      # Shortcut to set flash.now message. Same rules applied from set_flash_message
      def set_now_flash_message(key, kind)
        set_flash_message(key, kind, true)
      end

      # Render a view for the specified scope. Turned off by default.
      # Accepts just :controller as option.
      def render_with_scope(action, options={})
        controller_name = options.delete(:controller) || self.controller_name

        if self.class.scoped_views
          begin
            render :template => "#{controller_name}/#{devise_mapping.as}/#{action}"
          rescue ActionView::MissingTemplate
            render action, :controller => controller_name
          end
        else
          render action, :controller => controller_name
        end
      end

    end
  end
end
