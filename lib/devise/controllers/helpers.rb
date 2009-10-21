module Devise
  module Controllers
    module Helpers

      def self.included(base)
        base.class_eval do
          helper_method :resource, :resource_name, :resource_class, :devise_mapping
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

      # Proxy to devise map class
      def resource_class
        devise_mapping.to
      end

    protected

      # Redirects to stored uri before signing in or the default path and clear
      # return to.
      def redirect_back_or_to(default)
        redirect_to(return_to || default)
        clear_return_to
      end

      # Access to scoped stored uri
      def return_to
        session[:"#{resource_name}.return_to"]
      end

      # Clear scoped stored uri
      def clear_return_to
        session[:"#{resource_name}.return_to"] = nil
      end

      # Checks for the existence of the resource root path. If it exists,
      # returns it, otherwise returns the default root_path.
      # Used after authenticating a user, confirming it's account or updating
      # it's password, so we are able to redirect to scoped root paths.
      # Examples (for a user scope):
      #   map.user_root '/users', :controller => 'users' # creates user_root_path
      #
      #   map.namespace :users do |users|
      #     users.root # creates user_root_path
      #   end
      def home_or_root_path
        home_path = :"#{resource_name}_root_path"
        respond_to?(home_path, true) ? send(home_path) : root_path
      end

      # Attempt to find the mapped route for devise based on request path
      def devise_mapping
        @devise_mapping ||= Devise.find_mapping_by_path(request.path)
      end

      # Sets the resource creating an instance variable
      def resource=(new_resource)
        instance_variable_set(:"@#{resource_name}", new_resource)
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

    end
  end
end
