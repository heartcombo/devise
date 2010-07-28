module Devise
  module Oauth
    module InternalHelpers
      extend ActiveSupport::Concern

      def self.define_oauth_helpers(name) #:nodoc:
        alias_method(name, :callback_action)
        public name
      end

      included do
        helpers = %w(oauth_config)
        hide_action *helpers
        helper_method *helpers
        before_filter :valid_oauth_callback?, :oauth_error_happened?
      end

      # Returns the oauth_callback (also aliased as oauth_provider) as a symbol.
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
      #   * If the URL being accessed is a valid provider for the given scope;
      #   * If code or error was streamed back from the server;
      #   * If the resource class implements the required hook;
      #
      def valid_oauth_callback?
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

      # Check if an error was sent by the authorizer. If it happened, we redirect
      # to url specified by after_oauth_failure_path_for, which defaults to new_session_path.
      #
      # By default, Devise shows a custom message from I18n saying the user could
      # not be authenticated and the reason:
      #
      #   en:
      #     devise:
      #       oauth_callbacks:
      #         failure: 'Could not authorize you from %{kind} because "%{reason}".'
      #
      # Let's suppose the reason returned by a Github was "access_denied". It will show:
      #
      #   Could not authorize you from Github because "Access denied"
      #
      # And it will also be logged on console:
      #
      #   github oauth failed: "access_denied".
      #
      # However, each specific error message can be customized using I18n:
      #
      #   en:
      #     devise:
      #       oauth_callbacks:
      #         access_denied: 'You did not give access to our application on %{kind}.'
      #
      # Note "access_denied" follows the same lookup rule described in set_oauth_flash_message
      # method. Besides, is important to remember most errors are specified by OAuth 2
      # specification. But a few providers do not use them yet.
      #
      # TODO: Currently, Facebook is returning error_reason=user_denied when
      # the user denies, but the specification defines error=access_denied instead.
      def oauth_error_happened?
        if error = params[:error] || params[:error_reason]
          # Some providers returns access-denied instead of access_denied.
          error = error.to_s.gsub("-", "_")
          logger.warn "[Devise] #{oauth_callback} oauth failed: #{error.inspect}."

          set_oauth_flash_message :alert, error[0,25], :default => :failure, :reason => error.humanize
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

      # This is the implementation for all OAuth actions.
      def callback_action
        access_token  = oauth_config.access_token_by_code(params[:code], oauth_redirect_uri)
        self.resource = resource_class.send(oauth_model_callback, access_token, signed_in_resource)

        if resource.persisted? && resource.errors.empty?
          set_oauth_flash_message :notice, :success
          sign_in_and_redirect resource_name, resource, :event => :authentication
        else
          session[oauth_session_key] = access_token.token
          clean_up_passwords(resource)
          render_for_oauth
        end
      end

      # Handles oauth flash messages by adding a cascade. The default messages
      # are always in the controller namespace:
      #
      #   en:
      #     devise:
      #       oauth_callbacks:
      #         success: 'Successfully authorized from %{kind} account.'
      #         failure: 'Could not authorize you from %{kind} because "%{reason}".'
      #         skipped: 'Skipped Oauth authorization for %{kind}.'
      #
      # But they can also be nested according to the oauth provider:
      #
      #   en:
      #     devise:
      #       oauth_callbacks:
      #         github:
      #           success: 'Hello coder! Welcome to our app!'
      #
      # And finally by Devise scope:
      #
      #   en:
      #     devise:
      #       oauth_callbacks:
      #         admin:
      #           github:
      #             success: 'Hello coder with high permissions! Can I get a raise?'
      #
      def set_oauth_flash_message(key, type, options={})
        options[:kind]    = oauth_callback.to_s.titleize
        options[:default] = Array(options[:default]).unshift(type.to_sym)
        set_flash_message(key, "#{oauth_callback}.#{type}", options)
      end

      # Choose which template to render when a not persisted resource is
      # returned in the find_for_x_oauth. By default, it renders registrations/new.
      def render_for_oauth
        render_with_scope :new, devise_mapping.controllers[:registrations]
      end

      # The default hook used by oauth to specify the redirect url for success.
      def after_oauth_success_path_for(resource_or_scope)
        after_sign_in_path_for(resource_or_scope)
      end

      # The default hook used by oauth to specify the redirect url for failure.
      def after_oauth_failure_path_for(scope)
        new_session_path(scope)
      end

      # Overwrite redirect_for_sign_in so it takes uses after_oauth_success_path_for.
      def redirect_for_sign_in(scope, resource) #:nodoc:
        redirect_to stored_location_for(scope) || after_oauth_success_path_for(resource)
      end
    end
  end
end