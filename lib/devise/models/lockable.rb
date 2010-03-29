require 'devise/models/activatable'

module Devise
  module Models

    # Handles blocking a user access after a certain number of attempts.
    # Lockable accepts two different strategies to unlock a user after it's
    # blocked: email and time. The former will send an email to the user when
    # the lock happens, containing a link to unlock it's account. The second
    # will unlock the user automatically after some configured time (ie 2.hours).
    # It's also possible to setup lockable to use both email and time strategies.
    #
    # Configuration:
    #
    #   maximum_attempts: how many attempts should be accepted before blocking the user.
    #   unlock_strategy: unlock the user account by :time, :email or :both.
    #   unlock_in: the time you want to lock the user after to lock happens. Only
    #              available when unlock_strategy is :time or :both.
    #
    module Lockable
      extend ActiveSupport::Concern
      include Devise::Models::Activatable

      # Lock an user setting it's locked_at to actual time.
      def lock_access!
        return true if access_locked?
        self.locked_at = Time.now

        if self.class.unlock_strategy_enabled?(:email)
          generate_unlock_token
          send_unlock_instructions
        end

        save(:validate => false)
      end

      # Unlock an user by cleaning locket_at and failed_attempts.
      def unlock_access!
        if_access_locked do
          self.locked_at = nil
          self.failed_attempts = 0
          self.unlock_token = nil
          save(:validate => false)
        end
      end

      # Verifies whether a user is locked or not.
      def access_locked?
        locked_at && !lock_expired?
      end

      # Send unlock instructions by email
      def send_unlock_instructions
        ::Devise::Mailer.unlock_instructions(self).deliver
      end

      # Resend the unlock instructions if the user is locked.
      def resend_unlock_token
        if_access_locked { send_unlock_instructions }
      end

      # Overwrites active? from Devise::Models::Activatable for locking purposes
      # by verifying whether an user is active to sign in or not based on locked?
      def active?
        super && !access_locked?
      end

      # Overwrites invalid_message from Devise::Models::Authenticatable to define
      # the correct reason for blocking the sign in.
      def inactive_message
        access_locked? ? :locked : super
      end

      # Overwrites valid_for_authentication? from Devise::Models::Authenticatable
      # for verifying whether an user is allowed to sign in or not. If the user
      # is locked, it should never be allowed.
      def valid_for_authentication?(attributes)
        if result = super
          self.failed_attempts = 0
        else
          self.failed_attempts += 1
          lock_access! if failed_attempts > self.class.maximum_attempts
        end
        save(:validate => false) if changed?
        result
      end

      protected

        # Generates unlock token
        def generate_unlock_token
          self.unlock_token = self.class.unlock_token
        end

        # Tells if the lock is expired if :time unlock strategy is active
        def lock_expired?
          if self.class.unlock_strategy_enabled?(:time)
            locked_at && locked_at < self.class.unlock_in.ago
          else
            false
          end
        end

        # Checks whether the record is locked or not, yielding to the block
        # if it's locked, otherwise adds an error to email.
        def if_access_locked
          if access_locked?
            yield
          else
            self.errors.add(:email, :not_locked)
            false
          end
        end

      module ClassMethods
        # Attempt to find a user by it's email. If a record is found, send new
        # unlock instructions to it. If not user is found, returns a new user
        # with an email not found error.
        # Options must contain the user email
        def send_unlock_instructions(attributes={})
         lockable = find_or_initialize_with_error_by(:email, attributes[:email], :not_found)
         lockable.resend_unlock_token if lockable.persisted?
         lockable
        end

        # Find a user by it's unlock token and try to unlock it.
        # If no user is found, returns a new user with an error.
        # If the user is not locked, creates an error for the user
        # Options must have the unlock_token
        def unlock_access_by_token(unlock_token)
          lockable = find_or_initialize_with_error_by(:unlock_token, unlock_token)
          lockable.unlock_access! if lockable.persisted?
          lockable
        end

        # Is the unlock enabled for the given unlock strategy?
        def unlock_strategy_enabled?(strategy)
          [:both, strategy].include?(self.unlock_strategy)
        end

        def unlock_token
          Devise.friendly_token
        end

        Devise::Models.config(self, :maximum_attempts, :unlock_strategy, :unlock_in)
      end
    end
  end
end
