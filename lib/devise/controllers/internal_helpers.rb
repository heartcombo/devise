module Devise
  module Controllers
    # Those helpers are used only inside Devise controllers and should not be
    # included in ApplicationController since they all depend on the url being
    # accessed.
    module InternalHelpers #:nodoc:
      extend ActiveSupport::Concern
      include Devise::Controllers::ScopedViews

      included do
        unloadable

        helpers = %w(resource scope_name resource_name
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
        raise ActionController::UnknownAction unless devise_mapping &&
          devise_mapping.allowed_controllers.include?(controller_path)
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
        flash_hash[key] = I18n.t(:"#{resource_name}.#{kind}", :resource_name => resource_name,
                                 :scope => [:devise, controller_name.to_sym], :default => kind)
      end

      # Shortcut to set flash.now message. Same rules applied from set_flash_message
      def set_now_flash_message(key, kind)
        set_flash_message(key, kind, true)
      end

      def clean_up_passwords(object)
        object.clean_up_passwords if object.respond_to?(:clean_up_passwords)
      end
    end
  end
end
