# frozen_string_literal: true

module Devise
  module TwoFactor
    module UrlHelpers
      def new_two_factor_challenge_path(resource_or_scope, method, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        context = _route_context_for(resource_or_scope)
        context.send(:"#{scope}_new_two_factor_#{method}_path", *args)
      end

      def new_two_factor_challenge_url(resource_or_scope, method, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        context = _route_context_for(resource_or_scope)
        context.send(:"#{scope}_new_two_factor_#{method}_url", *args)
      end

      def two_factor_path(resource_or_scope, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        context = _route_context_for(resource_or_scope)
        context.send(:"#{scope}_two_factor_path", *args)
      end

      def two_factor_url(resource_or_scope, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        context = _route_context_for(resource_or_scope)
        context.send(:"#{scope}_two_factor_url", *args)
      end

      private

      def _route_context_for(resource_or_scope)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        router_name = Devise.mappings[scope].router_name
        router_name ? send(router_name) : _devise_route_context
      end
    end
  end
end
