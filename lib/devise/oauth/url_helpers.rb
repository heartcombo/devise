module Devise
  module Oauth
    module UrlHelpers
      def self.define_helpers(mapping)
        class_eval <<-URL_HELPERS, __FILE__, __LINE__ + 1
          def #{mapping}_oauth_authorize_url(provider, options={})
            if config = Devise.oauth_configs[provider.to_sym]
              options[:redirect_uri] ||= #{mapping}_oauth_callback_url(provider.to_s)
              config.authorize_url(options)
            else
              raise ArgumentError, "Could not find oauth provider \#{provider.inspect}"
            end
          end
        URL_HELPERS
      end

      def oauth_authorize_url(resource_or_scope, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        send("#{scope}_oauth_authorize_url", *args)
      end

      def oauth_callback_url(resource_or_scope, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        send("#{scope}_oauth_callback_path", *args)
      end

      def oauth_callback_path(resource_or_scope, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        send("#{scope}_oauth_callback_path", *args)
      end
    end
  end
end