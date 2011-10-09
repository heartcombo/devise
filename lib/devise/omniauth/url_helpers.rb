module Devise
  module OmniAuth
    module UrlHelpers
      def self.define_helpers(mapping)
        return unless mapping.omniauthable?
        method = "#{mapping.name}_omniauth_authorize_path"

        class_eval <<-URL_HELPERS, __FILE__, __LINE__ + 1
          def #{method}(provider, params = {})
            if Devise.omniauth_configs[provider.to_sym]
              script_name = request.env["SCRIPT_NAME"]

              path = "\#{script_name}/#{mapping.path}/auth/\#{provider}\".squeeze("/")
              path << '?' + params.to_param if params.present?
              path
            else
              raise ArgumentError, "Could not find omniauth provider \#{provider.inspect}"
            end
          end
          protected :#{method}
        URL_HELPERS
      end

      protected

      def omniauth_authorize_path(resource_or_scope, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        send("#{scope}_omniauth_authorize_path", *args)
      end

      def omniauth_callback_path(resource_or_scope, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        send("#{scope}_omniauth_callback_path", *args)
      end
    end
  end
end
