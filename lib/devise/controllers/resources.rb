module Devise
  module Controllers
    module Resources

      def resource_name(object=nil)
        @resource_name ||= Devise.resource_name(resource_name_or_request_path(object))
      end

      def resource_class
        @resource_class ||= Devise.resource_class(resource_name_or_request_path)
      end

      private

        def resource_name_or_request_path(object=nil)
          object ? object.class.name : request.path.split('/').second
        end
    end
  end
end
