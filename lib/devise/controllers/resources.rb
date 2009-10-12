module Devise
  module Controllers
    module Resources

    protected

      def resource
        instance_variable_get(:"@#{resource_name}")
      end

      def resource=(new_resource)
        instance_variable_set(:"@#{resource_name}", new_resource)
      end

      def resource_name
        devise_mapping.name
      end

      def resource_class
        devise_mapping.to
      end

      def devise_mapping
        @devise_mapping ||= Devise.find_mapping_by_path(request.path)
      end

      # TODO Test me
      def find_resource_class
        render :status => :not_found unless devise_mapping
      end

    end
  end
end
