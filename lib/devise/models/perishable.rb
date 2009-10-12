module Devise
  module Models

    # Perishable is mainly responsible for recreating tokens used inside
    # Recoverable and Confirmable modules.
    # It also has some utility class methods to find or initialize records based
    # on perishable_token or email, and adding an error to specific fields if no
    # record is found.
    # Examples:
    #   # create a new token and save the record, without validating
    #   User.find(1).reset_perishable_token!
    #   # only create a new token, without saving the record
    #   user = User.find(1)
    #   user.reset_perishable_token
    #
    module Perishable

      def self.included(base)
        base.class_eval do
          extend ClassMethods
          before_create :reset_perishable_token
        end
      end

      # Generates a new random token for confirmation, based on actual Time and salt
      #
      def reset_perishable_token
        self.perishable_token = secure_digest(Time.now.utc, random_string, password)
      end

      # Resets the perishable token with and save the record without validating
      #
      def reset_perishable_token!
        reset_perishable_token and save(false)
      end

      module ClassMethods

        # Attempt to find a user by and incoming perishable_token. If no user is
        # found, initialize a new one and adds an :invalid error to perishable_token
        #
        def find_or_initialize_with_error_by_perishable_token(perishable_token)
          perishable = find_or_initialize_by_perishable_token(perishable_token)
          if perishable.new_record?
            perishable.errors.add(:perishable_token, :invalid, :default => 'invalid confirmation')
          end
          perishable
        end

        # Attempt to find a user by it's email. If not user is found, returns a
        # new user with an email not found error.
        #
        def find_or_initialize_with_error_by_email(email)
          perishable = find_or_initialize_by_email(email)
          if perishable.new_record?
            perishable.errors.add(:email, :not_found, :default => 'not found')
          end
          perishable
        end

      end
    end
  end
end
