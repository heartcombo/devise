module Devise
  module Controllers
    module Helpers

      def self.included(base)
        base.class_eval do
          helper_method :resource, :resource_name, :resource_class, :devise_mapping
        end
      end

      def resource
        instance_variable_get(:"@#{resource_name}")
      end

      def resource_name
        devise_mapping.name
      end

      def resource_class
        devise_mapping.to
      end

    protected

      def devise_mapping
        @devise_mapping ||= Devise.find_mapping_by_path(request.path)
      end

      def resource=(new_resource)
        instance_variable_set(:"@#{resource_name}", new_resource)
      end

      def set_flash_message(key, kind)
        flash[key] = I18n.t(:"#{resource_name}.#{kind}",
                            :scope => [:devise, controller_name.to_sym], :default => kind)
      end

    end
  end
end
