module Devise
  module Confirmable
    require 'devise/models/perishable'

    def self.included(base)
      base.class_eval do
        include ::Devise::Perishable
        extend ClassMethods

        after_create  :send_confirmation_instructions
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

    private

      # Send confirmation instructions by email
      #
      def send_confirmation_instructions
        ::Notifier.deliver_confirmation_instructions(self)
      end

    module ClassMethods

      # Hook default authenticate to test whether the account is confirmed or not
      # Returns the authenticated_user if it's confirmed, otherwise returns nil
      #
      def authenticate(email, password)
        confirmable = super
        confirmable if confirmable.confirmed? unless confirmable.nil?
      end

      # Find a user by it's confirmation token and try to confirm it.
      # If no user is found, returns a new user
      # If the user is already confirmed, create an error for the user
      #
      def find_and_confirm(perishable_token)
        confirmable = find_or_initialize_with_error_by_perishable_token(perishable_token)
        confirmable.confirm! unless confirmable.new_record?
        confirmable
      end
    end
  end
end
