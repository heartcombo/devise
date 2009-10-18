module Devise
  module Models

    # Confirmable is responsible to verify if an account is already confirmed to
    # sign in, and to send emails with confirmation instructions.
    # Confirmation instructions are sent to the user email after creating a
    # record, after updating it's email and also when manually requested by
    # a new confirmation instruction request.
    # Whenever the user update it's email, his account is automatically unconfirmed,
    # it means it won't be able to sign in again without confirming the account
    # again through the email that was sent.
    # Examples:
    #
    #   User.find(1).confirm!      # returns true unless it's already confirmed
    #   User.find(1).confirmed?    # true/false
    #   User.find(1).send_confirmation_instructions # manually send instructions
    #   User.find(1).reset_confirmation! # reset confirmation status and send instructions
    module Confirmable

      def self.included(base)
        base.class_eval do
          extend ClassMethods

          before_save :reset_confirmation, :if => :email_changed?
          after_save  :send_confirmation_instructions, :if => :email_changed?
        end
      end

      # Confirm a user by setting it's confirmed_at to actual time. If the user
      # is already confirmed, add en error to email field
      def confirm!
        unless_confirmed do
          clear_confirmation_token
          update_attribute(:confirmed_at, Time.now)
        end
      end

      # Verifies whether a user is confirmed or not
      def confirmed?
        !new_record? && confirmed_at?
      end

      # Send confirmation instructions by email
      def send_confirmation_instructions
        ::Notifier.deliver_confirmation_instructions(self)
      end

      # Remove confirmation date and send confirmation instructions, to ensure
      # after sending these instructions the user won't be able to sign in without
      # confirming it's account
      def reset_confirmation!
        unless_confirmed do
          reset_confirmation
          save(false)
          send_confirmation_instructions
        end
      end

      private

        # Remove confirmation date from the user, ensuring after a user update
        # it's email, it won't be able to sign in without confirming it.
        def reset_confirmation
          generate_confirmation_token
          self.confirmed_at = nil
        end

        # Checks whether the record is confirmed or not, yielding to the block
        # if it's already confirmed, otherwise adds an error to email.
        def unless_confirmed
          unless confirmed?
            yield
          else
            errors.add(:email, :already_confirmed, :default => 'already confirmed')
            false
          end
        end

        # Generates a new random token for confirmation, and stores the time
        # this token is being generated
        def generate_confirmation_token
          self.confirmation_token = friendly_token
          self.confirmation_sent_at = Time.now.utc
        end

        # Resets the confirmation token with and save the record without
        # validating.
        def generate_confirmation_token!
          generate_confirmation_token && save(false)
        end

        # Removes confirmation token
        def clear_confirmation_token
          self.confirmation_token = nil
        end

      module ClassMethods

        # Attempt to find a user by it's email. If a record is found, send new
        # confirmation instructions to it. If not user is found, returns a new user
        # with an email not found error.
        # Options must contain the user email
        def send_confirmation_instructions(attributes={})
          confirmable = find_or_initialize_with_error_by_email(attributes[:email])
          confirmable.reset_confirmation! unless confirmable.new_record?
          confirmable
        end

        # Find a user by it's confirmation token and try to confirm it.
        # If no user is found, returns a new user with an error.
        # If the user is already confirmed, create an error for the user
        # Options must have the confirmation_token
        def confirm!(attributes={})
          confirmable = find_or_initialize_by_confirmation_token(attributes[:confirmation_token])
          if confirmable.new_record?
            confirmable.errors.add(:confirmation_token, :invalid)
          else
            confirmable.confirm!
          end
          confirmable
        end
      end
    end
  end
end
