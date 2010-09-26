module Devise
  module Oauth
    # Provides a few helpers that are included in ActionController::Base
    # for convenience.
    module Helpers
      extend ActiveSupport::Concern

    protected

      # Overwrite expire_session_data_after_sign_in! so it removes all
      # oauth tokens from session ensuring registrations done in a row
      # do not try to store the same token in the database. 
      def expire_session_data_after_sign_in!
        super
        session.keys.grep(/_oauth_token$/).each { |k| session.delete(k) }
      end
    end
  end
end