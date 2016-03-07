module Devise
  module OmniAuth
    module UrlHelpers
      def self.define_helpers(mapping)
      end

      def omniauth_authorize_path(resource_or_scope, provider, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        _devise_route_context.send("#{scope}_#{provider}_omniauth_authorize_path", *args)
      end

      def omniauth_callback_path(resource_or_scope, provider, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        _devise_route_context.send("#{scope}_#{provider}_omniauth_callback_path", *args)
      end
    end
  end
end
