module Devise
  module Strategies
    # Base strategy for Devise. Responsible for verifying correct scope and mapping.
    class Base < ::Warden::Strategies::Base
      # Validate strategy. By default will raise an error if no scope or an
      # invalid mapping is found.
      def valid?
        raise "Could not find mapping for #{scope}" unless mapping
        mapping.for.include?(klass_type)
      end

      # Checks if a valid scope was given for devise and find mapping based on
      # this scope.
      def mapping
        Devise.mappings[scope]
      end

      # Store this class type.
      def klass_type
        @klass_type ||= self.class.name.split("::").last.underscore.to_sym
      end
    end
  end
end
