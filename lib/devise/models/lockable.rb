module Devise
  module Models
    # Handles blocking a user access after a certain number of attempts.
    # Lockable accepts two different strategies to unlock a user after it's
    # blocked: email and time. The former will send an email to the user when
    # the lock happens, containing a link to unlock its account. The second
    # will unlock the user automatically after some configured time (ie 2.hours).
    # It's also possible to setup lockable to use both email and time strategies.
    #
    # == Options
    #
    # Lockable adds the following options to +devise+:
    #
    #   * +maximum_attempts+: how many attempts should be accepted before blocking the user.
    #   * +lock_strategy+: lock the user account by :failed_attempts or :none.
    #   * +unlock_strategy+: unlock the user account by :time, :email, :both or :none.
    #   * +unlock_in+: the time you want to lock the user after to lock happens. Only available when unlock_strategy is :time or :both.
    #   * +unlock_keys+: the keys you want to use when locking and unlocking an account
    #
    module Lockable
      extend  ActiveSupport::Concern

      delegate :lock_strategy_enabled?, :unlock_strategy_enabled?, :to => "self.class"

      # Lock a user setting its locked_at to actual time.
      def lock_access!
        self.locked_at = Time.now

        if unlock_strategy_enabled?(:email)
          generate_unlock_token
          send_unlock_instructions
        end

        save(:validate => false)
      end

      # Unlock a user by cleaning locket_at and failed_attempts.
      def unlock_access!
        self.locked_at = nil
        self.failed_attempts = 0 if respond_to?(:failed_attempts=)
        self.unlock_token = nil  if respond_to?(:unlock_token=)
        save(:validate => false)
      end

      # Verifies whether a user is locked or not.
      def access_locked?
        locked_at && !lock_expired?
      end

      # Send unlock instructions by email
      def send_unlock_instructions
        ::Devise.mailer.unlock_instructions(self).deliver
      end

      # Resend the unlock instructions if the user is locked.
      def resend_unlock_token
        if_access_locked { send_unlock_instructions }
      end

      # Overwrites active_for_authentication? from Devise::Models::Activatable for locking purposes
      # by verifying whether a user is active to sign in or not based on locked?
      def active_for_authentication?
        super && !access_locked?
      end

      # Overwrites invalid_message from Devise::Models::Authenticatable to define
      # the correct reason for blocking the sign in.
      def inactive_message
        access_locked? ? :locked : super
      end

      # Overwrites valid_for_authentication? from Devise::Models::Authenticatable
      # for verifying whether a user is allowed to sign in or not. If the user
      # is locked, it should never be allowed.
      def valid_for_authentication?
        return super unless persisted? && lock_strategy_enabled?(:failed_attempts)

        # Unlock the user if the lock is expired, no matter
        # if the user can login or not (wrong password, etc)
        unlock_access! if lock_expired?

        case (result = super)
        when Symbol
          return result
        when TrueClass
          self.failed_attempts = 0
          save(:validate => false)
        else
          self.failed_attempts ||= 0
          self.failed_attempts += 1
          if attempts_exceeded?
            lock_access! unless access_locked?
            return :locked
          else
            save(:validate => false)
          end
        end

        result
      end

      protected

        def attempts_exceeded?
          self.failed_attempts > self.class.maximum_attempts
        end

        # Generates unlock token
        def generate_unlock_token
          self.unlock_token = self.class.unlock_token
        end

        # Tells if the lock is expired if :time unlock strategy is active
        def lock_expired?
          if unlock_strategy_enabled?(:time)
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
        # Attempt to find a user by its email. If a record is found, send new
        # unlock instructions to it. If not user is found, returns a new user
        # with an email not found error.
        # Options must contain the user email
        def send_unlock_instructions(attributes={})
         lockable = find_or_initialize_with_errors(unlock_keys, attributes, :not_found)
         lockable.resend_unlock_token if lockable.persisted?
         lockable
        end

        # Find a user by its unlock token and try to unlock it.
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

        # Is the lock enabled for the given lock strategy?
        def lock_strategy_enabled?(strategy)
          self.lock_strategy == strategy
        end

        def unlock_token
          Devise.friendly_token
        end

        Devise::Models.config(self, :maximum_attempts, :lock_strategy, :unlock_strategy, :unlock_in, :unlock_keys)
      end
    end
  end
end
