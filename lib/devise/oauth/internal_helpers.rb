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
        before_filter :valid_oauth_callback?, :error_happened?
      end

      # Returns the oauth_callback (also aliases oauth_provider) as a symbol.
      # For example: :github.
      def oauth_callback
        @oauth_callback ||= action_name.to_sym
      end
      alias :oauth_provider :oauth_callback

      # Returns the configuration object for this oauth callback.
      def oauth_config
        @oauth_client ||= resource_class.oauth_configs[oauth_callback]
      end

    protected

      # This method checks three things:
      #
      #   * If the URL being access is a valid provider for the given scope;
      #   * If code or error was streamed back from the server;
      #   * If the resource class implements the required hook;
      #
      def valid_oauth_callback? #:nodoc:
        unless oauth_config
          unknown_action! "Skipping #{oauth_callback} OAuth because configuration " <<
            "could not be found for model #{resource_name}."
        end

        unless params[:code] || params[:error] || params[:error_reason]
          unknown_action! "Skipping #{oauth_callback} OAuth because code nor error were sent."
        end

        unless resource_class.respond_to?(oauth_model_callback)
          raise "#{resource_class.name} does not respond to #{oauth_model_callback}. " <<
            "Check the OAuth section in the README for more information."
        end
      end

      # Check if an error was sent by the authorizer.
      #
      # TODO: Currently, Facebook is returning error_reason=user_defined when
      # the user denies, but the specification defines error=access_denied instead.
      def error_happened? #:nodoc:
        if error = params[:error] || params[:error_reason]
          logger.warn "#{oauth_callback} OAuth failed: #{error.inspect}."

         # Some providers returns access-denied instead of access_denied.
          error = error.to_s.gsub("-", "_")
          set_flash_message :alert, error[0,25], :default => :failure, :reason => error.titleize
          redirect_to after_oauth_failure_path_for(resource_name)
        end
      end

      # The model method used as hook.
      def oauth_model_callback #:nodoc:
        "find_for_#{oauth_callback}_oauth"
      end

      # The session key to store the token.
      def oauth_session_key #:nodoc:
        "#{resource_name}_#{oauth_callback}_oauth_token"
      end

      # The callback redirect uri. Used to request the access token.
      def oauth_redirect_uri #:nodoc:
        oauth_callback_url(resource_name, oauth_callback)
      end

      # This is the implementation for all actions in this controller.
      def callback_action
        access_token  = oauth_config.access_token_by_code(params[:code], oauth_redirect_uri)
        self.resource = resource_class.send(oauth_model_callback, access_token, signed_in_resource)

        if resource.persisted?
          set_flash_message :notice, oauth_callback, :default => :success
          sign_in_and_redirect resource_name, resource, :event => :authentication
        else
          session[oauth_session_key] = access_token.token
          render_for_oauth
        end
      end

      # Overwrite to automatically add kind to messages.
      def set_flash_message(key, kind, options={}) #:nodoc:
        options[:kind] = oauth_callback.to_s.titleize
        super
      end

      # Choose which template to render when a not persisted resource is
      # returned in the find_for_x_oauth. By default, it renders registrations/new.
      def render_for_oauth
        render_with_scope :new, devise_mapping.controllers[:registrations]
      end

      # The default hook used by oauth to specify the redirect url.
      def after_oauth_sign_in_path_for(resource_or_scope)
        after_sign_in_path_for(resource_or_scope)
      end

      # A callback to redirect your user to the proper location after create.
      def after_oauth_failure_path_for(scope)
        root_path
      end

      # Overwrite redirect_for_sign_in so it takes uses after_oauth_sign_in_path_for.
      def redirect_for_sign_in(scope, resource) #:nodoc:
        redirect_to stored_location_for(scope) || after_oauth_sign_in_path_for(resource)
      end
    end
  end
end