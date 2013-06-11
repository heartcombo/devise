module Devise
  module Models

    # Recoverable takes care of resetting the user password and send reset instructions.
    #
    # ==Options
    #
    # Recoverable adds the following options to devise_for:
    #
    #   * +reset_password_keys+: the keys you want to use when recovering the password for an account
    #
    # == Examples
    #
    #   # resets the user password and save the record, true if valid passwords are given, otherwise false
    #   User.find(1).reset_password!('password123', 'password123')
    #
    #   # only resets the user password, without saving the record
    #   user = User.find(1)
    #   user.reset_password('password123', 'password123')
    #
    #   # creates a new token and send it with instructions about how to reset the password
    #   User.find(1).send_reset_password_instructions
    #
    module Recoverable
      extend ActiveSupport::Concern

      def self.required_fields(klass)
        [:reset_password_sent_at, :reset_password_token]
      end

      # Update password saving the record and clearing token. Returns true if
      # the passwords are valid and the record was saved, false otherwise.
      def reset_password!(new_password, new_password_confirmation)
        self.password = new_password
        self.password_confirmation = new_password_confirmation

        if valid?
          clear_reset_password_token
          after_password_reset
        end

        save
      end

      # Resets reset password token and send reset password instructions by email
      def send_reset_password_instructions
        generate_reset_password_token! if should_generate_reset_token?
        send_devise_notification(:reset_password_instructions)
      end
      
      def reset_password_token!
        generate_reset_password_token! if should_generate_reset_token?
        self.reset_password_token
      end 
      
      # Checks if the reset password token sent is within the limit time.
      # We do this by calculating if the difference between today and the
      # sending date does not exceed the confirm in time configured.
      # Returns true if the resource is not responding to reset_password_sent_at at all.
      # reset_password_within is a model configuration, must always be an integer value.
      #
      # Example:
      #
      #   # reset_password_within = 1.day and reset_password_sent_at = today
      #   reset_password_period_valid?   # returns true
      #
      #   # reset_password_within = 5.days and reset_password_sent_at = 4.days.ago
      #   reset_password_period_valid?   # returns true
      #
      #   # reset_password_within = 5.days and reset_password_sent_at = 5.days.ago
      #   reset_password_period_valid?   # returns false
      #
      #   # reset_password_within = 0.days
      #   reset_password_period_valid?   # will always return false
      #
      def reset_password_period_valid?
        reset_password_sent_at && reset_password_sent_at.utc >= self.class.reset_password_within.ago
      end

      protected

        def should_generate_reset_token?
          reset_password_token.nil? || !reset_password_period_valid?
        end

        # Generates a new random token for reset password
        def generate_reset_password_token
          self.reset_password_token = self.class.reset_password_token
          self.reset_password_sent_at = Time.now.utc
          self.reset_password_token
        end

        # Resets the reset password token with and save the record without
        # validating
        def generate_reset_password_token!
          generate_reset_password_token && save(:validate => false)
        end

        # Removes reset_password token
        def clear_reset_password_token
          self.reset_password_token = nil
          self.reset_password_sent_at = nil
        end

        def after_password_reset
        end

      module ClassMethods
        # Attempt to find a user by its email. If a record is found, send new
        # password instructions to it. If user is not found, returns a new user
        # with an email not found error.
        # Attributes must contain the user's email
        def send_reset_password_instructions(attributes={})
          recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
          recoverable.send_reset_password_instructions if recoverable.persisted?
          recoverable
        end

        # Generate a token checking if one does not already exist in the database.
        def reset_password_token
          generate_token(:reset_password_token)
        end

        # Attempt to find a user by its reset_password_token to reset its
        # password. If a user is found and token is still valid, reset its password and automatically
        # try saving the record. If not user is found, returns a new user
        # containing an error in reset_password_token attribute.
        # Attributes must contain reset_password_token, password and confirmation
        def reset_password_by_token(attributes={})
          recoverable = find_or_initialize_with_error_by(:reset_password_token, attributes[:reset_password_token])
          if recoverable.persisted?
            if recoverable.reset_password_period_valid?
              recoverable.reset_password!(attributes[:password], attributes[:password_confirmation])
            else
              recoverable.errors.add(:reset_password_token, :expired)
            end
          end
          recoverable
        end

        Devise::Models.config(self, :reset_password_keys, :reset_password_within)
      end
    end
  end
end
