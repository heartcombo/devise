module Devise
  module Strategies
    # Base strategy for Devise. Responsible for verifying correct scope and mapping.
    class Base < ::Warden::Strategies::Base
      # Checks if a valid scope was given for devise and find mapping based on
      # this scope.
      def mapping
        @mapping ||= begin
          mapping = Devise.mappings[scope]
          raise "Could not find mapping for #{scope}" unless mapping
          mapping
        end
      end

      # Check if the resource is active before signing him in once and for all.
      def success!(resource)
        if resource.respond_to?(:active?) && !resource.active?
          fail!(resource.inactive_message)
        else
          super
        end
      end
    end
  end
end
