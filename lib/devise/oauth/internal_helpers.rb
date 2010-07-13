module Devise
  module Oauth
    module InternalHelpers
      extend ActiveSupport::Concern

      def self.define_oauth_helpers(name)
        alias_method(name, :callback_action)
        public name
      end

      included do
        helpers = %w(oauth_config)
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

    protected

      def is_oauth_callback?
        unless params[:code]
          unknown_action! "Skipping OAuth #{outh_callback.inspect} callback because code was not sent."
        end

        unless oauth_config
          unknown_action! "Skipping OAuth #{outh_callback.inspect} callback because provider " <<
            "could not be found in model #{resource_name.inspect}."
        end

        unless resource_class.respond_to?(oauth_model_callback)
          raise "#{resource_class.name} does not respond to to OAuth callback #{oauth_model_callback.inspect}. " <<
            "Check the OAuth section in the README for more information."
        end
      end

      def oauth_model_callback
        "find_for_#{oauth_callback}_oauth"
      end

      def callback_action
        access_token  = oauth_config.access_token_by_code(params[:code])
        self.resource = resource_class.send(oauth_model_callback, access_token, signed_in_resource)

        if resource.persisted?
          set_flash_message :notice, oauth_callback, :default => :default, :kind => oauth_callback.to_s.titleize
          sign_in_and_redirect resource_name, resource, :event => :authentication
        else
          session[oauth_session_scope] = access_token.token
          render_for_oauth
        end
      end

      def oauth_session_scope
        "#{resource_name}_#{oauth_callback}_token"
      end

      # Overwrite redirect_for_sign_in so it takes uses after_oauth_sign_in_path_for.
      def redirect_for_sign_in(scope, resource) #:nodoc:
        redirect_to stored_location_for(scope) || after_oauth_sign_in_path_for(resource)
      end
    end
  end
end