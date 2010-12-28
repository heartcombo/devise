module Devise
  module Models

    # Recoverable takes care of reseting the user password and send reset instructions.
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

      # Update password saving the record and clearing token. Returns true if
      # the passwords are valid and the record was saved, false otherwise.
      def reset_password!(new_password, new_password_confirmation)
        self.password = new_password
        self.password_confirmation = new_password_confirmation
        clear_reset_password_token if valid?
        save
      end

      # Resets reset password token and send reset password instructions by email
      def send_reset_password_instructions
        generate_reset_password_token!
        ::Devise.mailer.reset_password_instructions(self).deliver
      end

      protected

        # Generates a new random token for reset password
        def generate_reset_password_token
          self.reset_password_token = self.class.reset_password_token
        end

        # Resets the reset password token with and save the record without
        # validating
        def generate_reset_password_token!
          generate_reset_password_token && save(:validate => false)
        end

        # Removes reset_password token
        def clear_reset_password_token
          self.reset_password_token = nil
        end

      module ClassMethods
        # Attempt to find a user by it's email. If a record is found, send new
        # password instructions to it. If not user is found, returns a new user
        # with an email not found error.
        # Attributes must contain the user email
        def send_reset_password_instructions(attributes={})
          recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
          recoverable.send_reset_password_instructions if recoverable.persisted?
          recoverable
        end

        # Generate a token checking if one does not already exist in the database.
        def reset_password_token
          generate_token(:reset_password_token)
        end

        def reset_password_keys
          [:email]
        end

        # Attempt to find a user by it's reset_password_token to reset it's
        # password. If a user is found, reset it's password and automatically
        # try saving the record. If not user is found, returns a new user
        # containing an error in reset_password_token attribute.
        # Attributes must contain reset_password_token, password and confirmation
        def reset_password_by_token(attributes={})
          recoverable = find_or_initialize_with_error_by(:reset_password_token, attributes[:reset_password_token])
          recoverable.reset_password!(attributes[:password], attributes[:password_confirmation]) if recoverable.persisted?
          recoverable
        end
      end
    end
  end
end
