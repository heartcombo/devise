# frozen_string_literal: true

require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    # Strategy for signing in a user through a one-time magic link token
    # sent by email. The token is only accepted while it's within the
    # configured time window and is consumed on the first successful
    # sign in, so it cannot be reused.
    class MagicLinkAuthenticatable < Authenticatable
      def valid?
        valid_params_request? && magic_link_token.present?
      end

      def authenticate!
        resource = mapping.to.with_magic_link_token(magic_link_token)

        if resource && resource.magic_link_period_valid?
          if validate(resource)
            resource.consume_magic_link_token!
            remember_me(resource)
            resource.after_magic_link_authentication
            success!(resource)
          end
        else
          fail(:magic_link_invalid)
        end
      end

      # A magic link sign in comes from a link clicked in an email, so there
      # is no password to clean up and CSRF data should still be reset.
      def clean_up_csrf?
        true
      end

    private

      def magic_link_token
        params[:magic_link_token]
      end
    end
  end
end

Warden::Strategies.add(:magic_link_authenticatable, Devise::Strategies::MagicLinkAuthenticatable)
