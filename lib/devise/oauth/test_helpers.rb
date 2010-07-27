module Devise
  module Oauth
    module TestHelpers #:nodoc:
      def self.short_circuit_authorizers!
        module_eval <<-ALIASES, __FILE__, __LINE__ + 1
          def oauth_authorize_url(scope, provider)
            oauth_callback_url(scope, provider, :code => "12345")
          end
        ALIASES

        Devise.mappings.each_value do |m|
          next unless m.oauthable?

          module_eval <<-ALIASES, __FILE__, __LINE__ + 1
            def #{m.name}_oauth_authorize_url(provider)
              #{m.name}_oauth_callback_url(provider, :code => "12345")
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