module Devise
  module OmniAuth
    module TestHelpers #:nodoc:
      def self.short_circuit_authorizers!
        module_eval <<-ALIASES, __FILE__, __LINE__ + 1
          def omniauth_authorize_path(*args)
            omniauth_callback_path(*args)
          end
        ALIASES

        Devise.mappings.each_value do |m|
          next unless m.omniauthable?

          module_eval <<-ALIASES, __FILE__, __LINE__ + 1
            def #{m.name}_omniauth_authorize_path(provider)
              #{m.name}_omniauth_callback_path(provider)
            end
          ALIASES
        end
      end

      def self.unshort_circuit_authorizers!
        module_eval do
          instance_methods.each { |m| remove_method(m) }
        end
      end
    end
  end
end