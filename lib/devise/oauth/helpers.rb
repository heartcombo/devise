module Devise
  module Oauth
    module Helpers
      extend ActiveSupport::Concern

      def self.create_action(name)
        alias_method(name, :callback_action)
        public name
      end

      included do
        helpers = %w(oauth_callback oauth_config oauth_client)
        hide_action *helpers
        helper_method *helpers
        before_filter :is_oauth_callback?
      end

      def oauth_callback
        @oauth_callback ||= action_name.to_sym
      end

      def oauth_config
        @oauth_client ||= resource_class.oauth_configs[oauth_callback]
      end

      def oauth_client
        @oauth_client ||= oauth_config.client
      end

    protected

      def is_oauth_callback?
        raise ActionController::UnknownAction unless oauth_config
        raise ActionController::UnknownAction unless params[:code]
      end

      def oauth_model_callback
        "authentication_for_#{oauth_callback}_oauth"
      end

      def callback_action
        access_token  = oauth_client.web_server.get_access_token(params[:code])
        self.resource = User.send(oauth_model_callback, access_token, signed_in_resource)

        if resource.persisted?
          sign_in_and_redirect resource_name, resource, :event => :authentication
        else
          render_for_oauth
        end
      end

      def render_for_oauth
        render_with_scope oauth_callback
      rescue ActionView::MissingTemplate
        render_with_scope :new, devise_mapping.controllers[:registrations]
      end

      # The default hook used by oauth to specify the redirect url.
      def after_oauth_sign_in_path_for(resource_or_scope)
        after_sign_in_path_for(resource_or_scope)
      end

      # Overwrite redirect_for_sign_in so it takes uses after_oauth_sign_in_path_for.
      def redirect_for_sign_in(scope, resource) #:nodoc:
        redirect_to stored_location_for(scope) || after_oauth_sign_in_path_for(resource)
      end
    end
  end
end