module Devise
  module Strategies
    # Base strategy for Devise. Responsible for verifying correct scope and
    # mapping.
    class Base < Warden::Strategies::Base

      # Validate strategy. By default will raise an error if no scope or an
      # invalid mapping is found.
      def valid?
        mapping.for.include?(self.class.name.split("::").last.underscore.to_sym)
      end

      # Checks if a valid scope was given for devise and find mapping based on
      # this scope.
      def mapping
        @mapping ||= begin
          raise "You need to give a scope for Devise authentication" unless scope
          raise "You need to give a valid Devise mapping"            unless mapping = Devise.mappings[scope]
          mapping
        end
      end
    end
  end
end
