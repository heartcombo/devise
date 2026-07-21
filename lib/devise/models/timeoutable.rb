# frozen_string_literal: true

require 'devise/hooks/timeoutable'

module Devise
  module Models
    # Timeoutable takes care of verifying whether a user session has already
    # expired or not. When a session expires after the configured time, the user
    # will be asked for credentials again, it means, they will be redirected
    # to the sign in page.
    #
    # == Options
    #
    # Timeoutable adds the following options to +devise+:
    #
    #   * +timeout_in+: the interval to timeout the user session without activity.
    #
    # +timeout_in+ also accepts a Hash to configure an absolute session timeout
    # in addition to (or instead of) the inactivity timeout:
    #
    #   * +:inactivity+: the interval to timeout the user session without activity.
    #   * +:max+: the maximum session length, timing out the user session once it
    #     is reached, regardless of activity.
    #
    # == Examples
    #
    #   user.timedout?(30.minutes.ago)
    #
    #   # Sign out after 30 minutes of inactivity, or 8 hours after signing in,
    #   # whichever comes first.
    #   config.timeout_in = { inactivity: 30.minutes, max: 8.hours }
    #
    module Timeoutable
      extend ActiveSupport::Concern

      def self.required_fields(klass)
        []
      end

      # Checks whether the user session has expired based on the configured
      # inactivity time.
      def timedout?(last_access)
        interval = inactivity_timeout
        !interval.nil? && last_access && last_access <= interval.ago
      end

      # Checks whether the user session has reached the configured maximum
      # duration, regardless of activity.
      def session_expired?(session_started_at)
        interval = max_session_timeout
        !interval.nil? && session_started_at && session_started_at <= interval.ago
      end

      def timeout_in
        self.class.timeout_in
      end

      # The inactivity timeout interval, or +nil+ when it is disabled.
      def inactivity_timeout
        timeout_in.is_a?(Hash) ? timeout_in[:inactivity] : timeout_in
      end

      # The maximum session duration, or +nil+ when it is disabled.
      def max_session_timeout
        timeout_in.is_a?(Hash) ? timeout_in[:max] : nil
      end

      private

      module ClassMethods
        Devise::Models.config(self, :timeout_in)
      end
    end
  end
end
