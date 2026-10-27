# frozen_string_literal: true

module Devise
  module TwoFactor
    # Keeps track of a sign-in that passed the first factor and waits for the
    # second one. The session stores a signed message bound to the scope that
    # expires after +two_factor_within+, so it cannot be tampered with or
    # reused for another scope.
    #
    # Included by the controllers and Warden strategies that start or finish
    # a two-factor sign-in. It only requires a +session+ method.
    module PendingSignIn
      protected

      # Stores the resource in the session until it passes the second factor.
      #
      # Example:
      #
      #   store_pending_sign_in_for(:user, user, remember_me: true)
      #
      def store_pending_sign_in_for(scope, resource, remember_me: false)
        model = Devise.mappings[scope].to

        session[pending_sign_in_key_for(scope)] = pending_sign_in_verifier.generate(
          { "record" => model.serialize_into_session(resource), "remember_me" => remember_me },
          purpose: scope, expires_in: model.two_factor_within
        )
      end

      # Returns true if the session holds a pending sign-in for the given scope.
      def pending_sign_in?(scope)
        session[pending_sign_in_key_for(scope)].present?
      end

      # Returns the resource that waits for the second factor, or nil when the
      # pending sign-in is missing, expired, tampered with or was stored for
      # another scope. It also checks the authenticatable salt, so a password
      # change cancels the pending sign-in.
      #
      # Like Warden does for signed-in users, it removes a pending sign-in
      # that can no longer be used from the session.
      def resource_from_pending_sign_in_for(scope)
        data = pending_sign_in_data_for(scope)
        resource = Devise.mappings[scope].to.serialize_from_session(*data["record"]) if data
        clear_pending_sign_in_for(scope) unless resource
        resource
      end

      # Returns the remember me choice made when the first factor passed.
      def remember_me_from_pending_sign_in?(scope)
        data = pending_sign_in_data_for(scope)
        data ? data["remember_me"] : false
      end

      # Removes the pending sign-in for the given scope from the session.
      def clear_pending_sign_in_for(scope)
        session.delete(pending_sign_in_key_for(scope))
      end

      private

      def pending_sign_in_data_for(scope)
        message = session[pending_sign_in_key_for(scope)]
        pending_sign_in_verifier.verified(message, purpose: scope) if message
      end

      def pending_sign_in_key_for(scope)
        "devise.two_factor.#{scope}"
      end

      def pending_sign_in_verifier
        Rails.application.message_verifier("devise.two_factor")
      end
    end
  end
end
