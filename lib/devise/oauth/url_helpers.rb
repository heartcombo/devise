module Devise
  module Oauth
    module UrlHelpers
      [:path, :url].each do |path_or_url|
        class_eval <<-URL_HELPERS, __FILE__, __LINE__ + 1
          def oauth_callback_#{path_or_url}(resource_or_scope, *args)
            scope = Devise::Mapping.find_scope!(resource_or_scope)
            send("\#{scope}_oauth_callback_#{path_or_url}", *args)
          end
        URL_HELPERS
      end

      def oauth_authorize_url(resource_or_scope, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        send("#{scope}_oauth_authorize_url}", *args)
      end

      Devise.mappings.each_key do |scope|
        class_eval <<-URL_HELPERS, __FILE__, __LINE__ + 1
          def #{scope}_oauth_authorize_url(provider, options={})
            if config = Devise.oauth_configs[provider.to_sym]
              options[:redirect_uri] ||= #{scope}_oauth_callback_url
              config.authorize_url(options)
            else
              raise ArgumentError, "Could not find oauth provider #{provider.inspect}"
            end
          end
        URL_HELPERS
      end
    end
  end
end