# frozen_string_literal: true

require 'devise/strategies/base'

module Devise
  module Strategies
    class TwoFactor < Base
      def valid?
        session["devise.two_factor.resource_id"].present?
      end

      def authenticate!
        resource = find_pending_resource
        return fail!(:two_factor_session_expired) unless resource
        return fail!(resource.unauthenticated_message) unless resource.valid_for_authentication? { true }

        verify_two_factor!(resource)

        unless halted?
          restore_remember_me(resource)
          resource.after_database_authentication
          cleanup_two_factor_session!
          success!(resource)
        end
      end

      # Extensions must override. Should call fail! with a specific
      # message on failure — this halts execution and triggers recall.
      def verify_two_factor!(resource)
        raise NotImplementedError, "#{self.class} must implement #verify_two_factor!"
      end

      private

      def find_pending_resource
        return unless session["devise.two_factor.resource_id"]
        mapping.to.where(id: session["devise.two_factor.resource_id"]).first
      end

      def restore_remember_me(resource)
        resource.remember_me = session["devise.two_factor.remember_me"] if resource.respond_to?(:remember_me=)
      end

      def cleanup_two_factor_session!
        session.delete("devise.two_factor.resource_id")
        session.delete("devise.two_factor.remember_me")
      end
    end
  end
end
