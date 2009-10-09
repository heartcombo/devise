module Devise
  module Models
    module Confirmable
      require 'devise/models/perishable'

      def self.included(base)
        base.class_eval do
          include ::Devise::Models::Perishable
          extend ClassMethods

          after_create  :send_confirmation_instructions
          before_update :reset_confirmation, :if => :email_changed?
          after_update  :send_confirmation_instructions, :if => :email_changed?
        end
      end

      # Confirm a user by setting it's confirmed_at to actual time. If the user
      # is already confirmed, add en error to email field
      #
      def confirm!
        unless confirmed?
          update_attribute(:confirmed_at, Time.now)
        else
          errors.add(:email, :already_confirmed, :default => 'already confirmed')
          false
        end
      end

      # Verifies whether a user is confirmed or not
      #
      def confirmed?
        !new_record? && confirmed_at?
      end

      # Send confirmation instructions by email
      #
      def send_confirmation_instructions
        ::Notifier.deliver_confirmation_instructions(self)
      end

      # Remove confirmation date and send confirmation instructions, to ensure
      # after sending these instructions the user won't be able to sign in without
      # confirming it's account
      #
      def reset_confirmation!
        reset_confirmation
        reset_perishable_token!
        send_confirmation_instructions
      end

      private

        # Remove confirmation date from the user, ensuring after a user update it's
        # email, it won't be able to sign in without confirming it.
        #
        def reset_confirmation
          self.confirmed_at = nil
        end

      module ClassMethods

        # Hook default authenticate to test whether the account is confirmed or not
        # Returns the authenticated_user if it's confirmed, otherwise returns nil
        #
        def authenticate(email, password)
          confirmable = super
          confirmable if confirmable.confirmed? unless confirmable.nil?
        end

        # Attempt to find a user by it's email. If a record is found, send new
        # confirmation instructions to it. If not user is found, returns a new user
        # with an email not found error.
        # Options must contain the user email
        #
        def send_confirmation_instructions(options={})
          confirmable = find_or_initialize_with_error_by_email(options[:email])
          confirmable.reset_confirmation! unless confirmable.new_record?
          confirmable
        end

        # Find a user by it's confirmation token and try to confirm it.
        # If no user is found, returns a new user
        # If the user is already confirmed, create an error for the user
        # Options must have the perishable_token
        #
        def confirm!(options={})
          confirmable = find_or_initialize_with_error_by_perishable_token(options[:perishable_token])
          confirmable.confirm! unless confirmable.new_record?
          confirmable
        end
      end
    end
  end
end
