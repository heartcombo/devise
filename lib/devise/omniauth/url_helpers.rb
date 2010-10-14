module Devise
  module OmniAuth
    module UrlHelpers
      def self.define_helpers(mapping)
        return unless mapping.omniauthable?

        class_eval <<-URL_HELPERS, __FILE__, __LINE__ + 1
          def #{mapping.name}_omniauth_authorize_path(provider)
            if Devise.omniauth_configs[provider.to_sym]
              "#{mapping.fullpath}/auth/\#{provider}"
            else
              raise ArgumentError, "Could not find omniauth provider \#{provider.inspect}"
            end
          end
        URL_HELPERS
      end

      def omniauth_authorize_path(resource_or_scope, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        send("#{scope}_omniauth_authorize_path", *args)
      end

      def omniauth_callback_url(resource_or_scope, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        send("#{scope}_omniauth_callback_path", *args)
      end
    end
  end
end