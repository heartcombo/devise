# frozen_string_literal: true

require 'devise/strategies/base'

module Devise
  module Strategies
    class TwoFactor < Base
      include Devise::TwoFactor::PendingSignIn

      def valid?
        pending_sign_in?(scope)
      end

      def authenticate!
        resource = resource_from_pending_sign_in_for(scope)
        return fail!(:two_factor_session_expired) unless resource
        return fail!(resource.unauthenticated_message) unless resource.valid_for_authentication? { true }

        verify_two_factor!(resource)

        unless halted?
          restore_remember_me(resource)
          resource.after_database_authentication
          clear_pending_sign_in_for(scope)
          success!(resource)
        end
      end

      # Extensions must override. Should call fail! with a specific
      # message on failure — this halts execution and triggers recall.
      def verify_two_factor!(resource)
        raise NotImplementedError, "#{self.class} must implement #verify_two_factor!"
      end

      private

      def restore_remember_me(resource)
        resource.remember_me = remember_me_from_pending_sign_in?(scope) if resource.respond_to?(:remember_me=)
      end
    end
  end
end
