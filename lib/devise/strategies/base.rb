module Devise
  module Strategies
    # Base strategy for Devise. Responsible for verifying correct scope and mapping.
    class Base < ::Warden::Strategies::Base
      # Checks if a valid scope was given for devise and find mapping based on this scope.
      def mapping
        @mapping ||= begin
          mapping = Devise.mappings[scope]
          raise "Could not find mapping for #{scope}" unless mapping
          mapping
        end
      end

    protected

      def succeeded?
        @result == :success
      end

      # Simply invokes valid_for_authentication? with the given block and deal with the result.
      def validate(resource, &block)
        result = resource && resource.valid_for_authentication?(&block)

        case result
        when Symbol, String
          fail!(result)
        else
          result
        end 
      end
    end
  end
end