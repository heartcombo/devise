# frozen_string_literal: true

module Devise
  module Models
    module TwoFactorAuthenticatable
      extend ActiveSupport::Concern

      def self.required_fields(klass)
        []
      end

      module ClassMethods
        Devise::Models.config(self, :two_factor_methods)

        def two_factor_methods=(methods)
          @two_factor_methods = methods
          Array(methods).each do |method_name|
            config = Devise.two_factor_method_configs[method_name]
            raise "Unknown two-factor method: #{method_name}. " \
              "Did you call Devise.register_two_factor_method?" unless config
            begin
              require config[:model]
            rescue LoadError
              raise unless config[:model].camelize.safe_constantize
            end
            mod = config[:model].camelize.constantize
            include mod
          end
        end

        def two_factor_modules
          Array(two_factor_methods)
        end
      end

      def enabled_two_factors
        self.class.two_factor_modules.select do |method_name|
          send(:"#{method_name}_two_factor_enabled?")
        end
      end

      def two_factor_enabled?
        enabled_two_factors.any?
      end
    end
  end
end
