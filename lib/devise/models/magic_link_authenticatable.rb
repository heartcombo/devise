# frozen_string_literal: true

require 'devise/strategies/magic_link_authenticatable'

module Devise
  module Models
    # MagicLinkAuthenticatable takes care of sending a one-time login link
    # (a.k.a. "magic link") by email and authenticating a user through it,
    # without requiring the user to type a password.
    #
    # The token sent in the e-mail is stored hashed in the database (in the
    # same fashion as the reset password token from Recoverable) and is
    # consumed on the first successful sign in, so each link can be used
    # only once. Tokens also expire after +magic_link_within+.
    #
    # ==Options
    #
    # MagicLinkAuthenticatable adds the following options to +devise+:
    #
    #   * +magic_link_keys+: the keys you want to use when requesting a
    #     magic link for an account. By default [:email].
    #   * +magic_link_within+: the time period within which the magic link
    #     must be used or the token expires. By default 20.minutes.
    #   * +magic_link_request_limit+: how many magic links can be requested
    #     for an account within +magic_link_request_period+, to prevent the
    #     email delivery from being spammed. Set to nil to disable rate
    #     limiting. By default 10.
    #   * +magic_link_request_period+: the time period used by
    #     +magic_link_request_limit+. Once the first request of the period is
    #     this old, the counter resets. By default 1.hour.
    #
    # All options can be set globally in the Devise initializer or per model
    # in the +devise+ call, which takes precedence over the global value:
    #
    #   # 5 magic links every 30 minutes for this model only
    #   devise :magic_link_authenticatable, magic_link_request_limit: 5,
    #          magic_link_request_period: 30.minutes
    #
    #   # disable rate limiting for this model only (the
    #   # magic_link_requests_count and magic_link_first_request_at
    #   # columns are not needed in this case)
    #   devise :magic_link_authenticatable, magic_link_request_limit: nil
    #
    # == Examples
    #
    #   # creates a new token and sends it as a magic link by email
    #   User.find(1).send_magic_link_instructions
    #
    #   # only verifies if a magic link can still be used
    #   User.find(1).magic_link_period_valid?
    #
    module MagicLinkAuthenticatable
      extend ActiveSupport::Concern

      def self.required_fields(klass)
        fields = [:magic_link_token, :magic_link_sent_at]
        fields += [:magic_link_requests_count, :magic_link_first_request_at] if klass.magic_link_request_limit
        fields
      end

      included do
        before_update :clear_magic_link_token, if: :clear_magic_link_token?
      end

      # Resets the magic link token and sends the magic link by email,
      # as long as the request rate limit was not exceeded (see
      # +magic_link_request_limit+ and +magic_link_request_period+).
      # Returns the raw token sent in the e-mail, or false when the
      # request was rate limited (with an error added to the record).
      def send_magic_link_instructions
        return false unless register_magic_link_request

        token = set_magic_link_token
        send_magic_link_instructions_notification(token)

        token
      end

      # Checks if the magic link token is still within the valid time window.
      # magic_link_within is a model configuration, must always be an integer value.
      #
      # Example:
      #
      #   # magic_link_within = 20.minutes and magic_link_sent_at = 10.minutes.ago
      #   magic_link_period_valid?   # returns true
      #
      #   # magic_link_within = 20.minutes and magic_link_sent_at = 20.minutes.ago
      #   magic_link_period_valid?   # returns false
      #
      def magic_link_period_valid?
        magic_link_sent_at && magic_link_sent_at.utc >= self.class.magic_link_within.ago.utc
      end

      # Removes the magic link token so the link can no longer be used, and
      # persists the change. Called after a successful sign in through a
      # magic link, making every link single-use.
      def consume_magic_link_token!
        clear_magic_link_token
        save(validate: false)
      end

      # A callback initiated after successfully authenticating through a
      # magic link. This can be used to insert your own logic that is only
      # run after the user successfully signs in with a magic link.
      #
      # Example:
      #
      #   def after_magic_link_authentication
      #     self.update_attribute(:invite_code, nil)
      #   end
      #
      def after_magic_link_authentication
      end

      # Checks if the resource already made as many magic link requests as
      # allowed within the current period. Returns false when rate limiting
      # is disabled (+magic_link_request_limit+ set to nil).
      def magic_link_request_limit_exceeded?
        return false unless self.class.magic_link_request_limit
        return false if magic_link_request_period_expired?

        magic_link_requests_count.to_i >= self.class.magic_link_request_limit
      end

      protected

        # Registers a magic link request against the rate limit, resetting
        # the counter when the period expired. When the limit was already
        # reached, adds an error to the record and returns false so no email
        # is sent. The updated counter is persisted along with the token by
        # +set_magic_link_token+.
        def register_magic_link_request
          return true unless self.class.magic_link_request_limit

          if magic_link_request_period_expired?
            self.magic_link_requests_count   = 0
            self.magic_link_first_request_at = Time.now.utc
          end

          if magic_link_requests_count.to_i >= self.class.magic_link_request_limit
            errors.add(:base, :magic_link_request_limit_exceeded,
              period: Devise::TimeInflector.time_ago_in_words(magic_link_request_period_resets_at))
            false
          else
            self.magic_link_requests_count = magic_link_requests_count.to_i + 1
            true
          end
        end

        # Checks if the current rate limiting period is over, meaning the
        # requests counter can be reset.
        def magic_link_request_period_expired?
          magic_link_first_request_at.nil? ||
            magic_link_first_request_at.utc < self.class.magic_link_request_period.ago.utc
        end

        # The time when the current rate limiting period is over and new
        # magic links can be requested again.
        def magic_link_request_period_resets_at
          magic_link_first_request_at.utc + self.class.magic_link_request_period
        end

        # Removes magic link token.
        def clear_magic_link_token
          self.magic_link_token   = nil
          self.magic_link_sent_at = nil
        end

        # Generates a new random token for the magic link and stores the
        # hashed version in the database, returning the raw token.
        def set_magic_link_token
          raw, enc = Devise.token_generator.generate(self.class, :magic_link_token)

          self.magic_link_token   = enc
          self.magic_link_sent_at = Time.now.utc
          save(validate: false)
          raw
        end

        def send_magic_link_instructions_notification(token)
          send_devise_notification(:magic_link_instructions, token, {})
        end

        # Invalidates outstanding magic links whenever the credentials used
        # to request them (or the password) change.
        def clear_magic_link_token?
          return false unless magic_link_token.present?

          encrypted_password_changed = devise_respond_to_and_will_save_change_to_attribute?(:encrypted_password)
          authentication_keys_changed = self.class.authentication_keys.any? do |attribute|
            devise_respond_to_and_will_save_change_to_attribute?(attribute)
          end

          authentication_keys_changed || encrypted_password_changed
        end

      module ClassMethods
        # Attempt to find a user by its magic link token. If a user is found
        # return it, otherwise return nil.
        def with_magic_link_token(token)
          magic_link_token = Devise.token_generator.digest(self, :magic_link_token, token)
          to_adapter.find_first(magic_link_token: magic_link_token)
        end

        # Attempt to find a user by its magic link keys (email by default).
        # If a record is found, send a magic link to it. If the user is not
        # found, returns a new user with an email not found error.
        # Attributes must contain the user's magic link keys.
        def send_magic_link_instructions(attributes = {})
          magic_link_authenticatable = find_or_initialize_with_errors(magic_link_keys, attributes, :not_found)
          magic_link_authenticatable.send_magic_link_instructions if magic_link_authenticatable.persisted?
          magic_link_authenticatable
        end

        Devise::Models.config(self, :magic_link_keys, :magic_link_within,
          :magic_link_request_limit, :magic_link_request_period)
      end
    end
  end
end
