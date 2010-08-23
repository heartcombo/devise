module Devise
  module Controllers
    # Those helpers are used only inside Devise controllers and should not be
    # included in ApplicationController since they all depend on the url being
    # accessed.
    module InternalHelpers #:nodoc:
      extend ActiveSupport::Concern
      include Devise::Controllers::ScopedViews

      included do
        helper DeviseHelper

        helpers = %w(resource scope_name resource_name signed_in_resource
                     resource_class devise_mapping devise_controller?)
        hide_action *helpers
        helper_method *helpers

        prepend_before_filter :is_devise_resource?
        skip_before_filter *Devise.mappings.keys.map { |m| :"authenticate_#{m}!" }
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

      # Returns a signed in resource from session (if one exists)
      def signed_in_resource
        warden.authenticate(:scope => resource_name)
      end

      # Attempt to find the mapped route for devise based on request path
      def devise_mapping
        @devise_mapping ||= request.env["devise.mapping"]
      end

      # Overwrites devise_controller? to return true
      def devise_controller?
        true
      end

    protected

      # Checks whether it's a devise mapped resource or not.
      def is_devise_resource? #:nodoc:
        unknown_action!("Could not find devise mapping for #{request.fullpath}.") unless devise_mapping
      end

      def unknown_action!(msg)
        logger.debug "[Devise] #{msg}" if logger
        raise ActionController::UnknownAction, msg
      end

      # Sets the resource creating an instance variable
      def resource=(new_resource)
        instance_variable_set(:"@#{resource_name}", new_resource)
      end

      # Build a devise resource.
      def build_resource(hash=nil)
        hash ||= params[resource_name] || {}
        self.resource = resource_class.new(hash)
      end

      # Helper for use in before_filters where no authentication is required.
      #
      # Example:
      #   before_filter :require_no_authentication, :only => :new
      def require_no_authentication
        if warden.authenticated?(resource_name)
          resource = warden.user(resource_name)
          redirect_to after_sign_in_path_for(resource)
        end
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
      def set_flash_message(key, kind, options={}) #:nodoc:
        options[:scope] = "devise.#{controller_name}"
        options[:default] = Array(options[:default]).unshift(kind.to_sym)
        options[:resource_name] = resource_name
        flash[key] = I18n.t("#{resource_name}.#{kind}", options)
      end

      def clean_up_passwords(object) #:nodoc:
        object.clean_up_passwords if object.respond_to?(:clean_up_passwords)
      end
    end
  end
end
