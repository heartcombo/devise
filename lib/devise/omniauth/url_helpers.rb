module Devise
  module OmniAuth
    module UrlHelpers
      def self.define_helpers(mapping)
        return unless mapping.omniauthable?

        mapping = mapping.name

        class_eval do
          define_method("#{mapping}_omniauth_authorize_path") do |provider, *args|
            ActiveSupport::Deprecation.warn(<<-DEPRECATION.strip_heredoc)
            [Devise] #{mapping}_omniauth_authorize_path(#{provider.inspect}) is deprecated and it will be removed from Devise 4.2.

            Please use #{mapping}_#{provider}_omniauth_authorize_path instead.
            DEPRECATION
            send("#{mapping}_#{provider}_omniauth_authorize_path", *args)
          end

          define_method("#{mapping}_omniauth_authorize_url") do |provider, *args|
            ActiveSupport::Deprecation.warn(<<-DEPRECATION.strip_heredoc)
            [Devise] #{mapping}_omniauth_authorize_url(#{provider.inspect}) is deprecated and it will be removed from Devise 4.2.

            Please use #{mapping}_#{provider}_omniauth_authorize_url instead.
            DEPRECATION
            send("#{mapping}_#{provider}_omniauth_authorize_url", *args)
          end

          define_method("#{mapping}_omniauth_callback_path") do |provider, *args|
            ActiveSupport::Deprecation.warn(<<-DEPRECATION.strip_heredoc)
            [Devise] #{mapping}_omniauth_callback_path(#{provider.inspect}) is deprecated and it will be removed from Devise 4.2.

            Please use #{mapping}_#{provider}_omniauth_callback_path instead.
            DEPRECATION
            send("#{mapping}_#{provider}_omniauth_callback_path", *args)
          end

          define_method("#{mapping}_omniauth_callback_url") do |provider, *args|
            ActiveSupport::Deprecation.warn(<<-DEPRECATION.strip_heredoc)
            [Devise] #{mapping}_omniauth_callback_url(#{provider.inspect}) is deprecated and it will be removed from Devise 4.2.

            Please use #{mapping}_#{provider}_omniauth_callback_url instead.
            DEPRECATION
            send("#{mapping}_#{provider}_omniauth_callback_url", *args)
          end
        end

        ActiveSupport.on_load(:action_controller) do
          if respond_to?(:helper_method)
            helper_method "#{mapping}_omniauth_authorize_path", "#{mapping}_omniauth_authorize_url"
            helper_method "#{mapping}_omniauth_callback_path", "#{mapping}_omniauth_callback_url"
          end
        end
      end

      def omniauth_authorize_path(resource_or_scope, provider, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        _devise_route_context.send("#{scope}_#{provider}_omniauth_authorize_path", *args)
      end

      def omniauth_authorize_url(resource_or_scope, provider, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        _devise_route_context.send("#{scope}_#{provider}_omniauth_authorize_url", *args)
      end

      def omniauth_callback_path(resource_or_scope, provider, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        _devise_route_context.send("#{scope}_#{provider}_omniauth_callback_path", *args)
      end

      def omniauth_callback_url(resource_or_scope, provider, *args)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        _devise_route_context.send("#{scope}_#{provider}_omniauth_callback_url", *args)
      end
    end
  end
end
