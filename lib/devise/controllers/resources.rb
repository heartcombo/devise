module Devise
  module Controllers
    module Resources

      def resource
        @resource ||= instance_variable_get(:"@#{resource_name}")
      end

      def resource=(new_resource)
        @resource = instance_variable_set(:"@#{resource_name}", new_resource)
      end

      def resource_name(object=nil)
        @resource_name ||= Devise.resource_name(resource_name_or_request_path(object))
      end

      def resource_class
        @resource_class ||= Devise.resource_class(resource_name_or_request_path)
      end

      private

        def resource_name_or_request_path(object=nil)
          object ? (object.is_a?(::ActiveRecord::Base) ? object.class.name.downcase : object) : request.path
        end
    end
  end
end
