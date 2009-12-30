require 'devise/models/activatable'

module Devise
  module Models

    module Lockable
      include Devise::Models::Activatable
      include Devise::Models::Authenticatable

      def self.included(base)
        base.class_eval do
          extend ClassMethods
        end
      end

      # Lock an user setting it's locked_at to actual time.
      def lock!
        self.locked_at = Time.now
        if [:both, :email].include?(self.class.unlock_strategy)
          generate_unlock_token
          self.send_unlock_instructions
        end
        save(false)
      end

      # Unlock an user by cleaning locket_at and failed_attempts
      def unlock!
        if_locked do
          self.locked_at = nil
          self.failed_attempts = 0
          self.unlock_token = nil
          save(false)
        end
      end

      # Verifies whether a user is locked or not
      def locked?
        self.locked_at && !lock_expired?
      end

      # Send unlock instructions by email
      def send_unlock_instructions
        ::DeviseMailer.deliver_unlock_instructions(self)
      end

      # Resend the unlock instructions if the user is locked
      def resend_unlock!
        if_locked do
          generate_unlock_token unless self.unlock_token.present?
          save(false)
          send_unlock_instructions
        end
      end

      # Overwrites active? from Devise::Models::Activatable for locking purposes
      # by verifying whether an user is active to sign in or not based on locked?
      def active?
        super && !locked?
      end

      # Overwrites valid_for_authentication? from Devise::Models::Authenticatable
      # for verifying whether an user is allowed to sign in or not. If the user
      # is locked, it should never be allowed.
      def valid_for_authentication?(attributes)
        unless result = super
          self.failed_attempts += 1
          save(false)
          self.lock! if self.failed_attempts > self.class.maximum_attempts
        else
          self.failed_attempts = 0
          save(false)
        end
        result
      end

      # Overwrites invalid_message from Devise::Models::Authenticatable to define
      # the correct reason for blocking the sign in.
      def inactive_message
        if locked?
          :locked
        else
          super
        end
      end

      protected

        # Generates unlock token
        def generate_unlock_token
          self.unlock_token = Devise.friendly_token
        end

        # Tells if the lock is expired if :time unlock strategy is active
        def lock_expired?
          if [:both, :time].include?(self.class.unlock_strategy)
            self.locked_at && self.locked_at < self.class.unlock_in.ago
          else
            false
          end
        end

        # Checks whether the record is locked or not, yielding to the block
        # if it's locked, otherwise adds an error to email.
        def if_locked
          if locked?
            yield
          else
            self.class.add_error_on(self, :email, :not_locked)
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
         lockable.resend_unlock! unless lockable.new_record?
         lockable
        end

        # Find a user by it's unlock token and try to unlock it.
        # If no user is found, returns a new user with an error.
        # If the user is not locked, creates an error for the user
        # Options must have the unlock_token
        def unlock!(attributes={})
          lockable = find_or_initialize_with_error_by(:unlock_token, attributes[:unlock_token])
          lockable.unlock! unless lockable.new_record?
          lockable
        end

        Devise::Models.config(self, :maximum_attempts, :unlock_strategy, :unlock_in)
      end
    end
  end
end