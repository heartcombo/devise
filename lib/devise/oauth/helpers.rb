module Devise
  module Oauth
    # Provides a few helpers that are included in ActionController::Base
    # for convenience.
    module Helpers
      extend ActiveSupport::Concern

      included do
        helper_method :oauth_callback
      end

      def oauth_callback
        nil
      end

    protected

      def render_for_oauth
        render_with_scope oauth_callback
      rescue ActionView::MissingTemplate
        render_with_scope :new, devise_mapping.controllers[:registrations]
      end

      # The default hook used by oauth to specify the redirect url.
      def after_oauth_sign_in_path_for(resource_or_scope)
        after_sign_in_path_for(resource_or_scope)
      end
    end
  end
end