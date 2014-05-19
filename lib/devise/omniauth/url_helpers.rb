module Devise
  module OmniAuth
    module UrlHelpers
      def self.define_helpers(mapping)
      end

      def self.define_group_helpers(group_name)
      end

      def omniauth_authorize_path(resource_or_scope, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        _devise_route_context.send("#{scope}_omniauth_authorize_path", *args)
      end

      def omniauth_callback_path(resource_or_scope, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        _devise_route_context.send("#{scope}_omniauth_callback_path", *args)
      end
    end
  end
end
