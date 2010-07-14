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
      alias :oauth_provider :oauth_callback
    end
  end
end