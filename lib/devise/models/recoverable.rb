module Devise
  module Models

    # Recoverable takes care of resetting the user password and send reset instructions.
    #
    # ==Options
    #
    # Recoverable adds the following options to devise_for:
    #
    #   * +reset_password_keys+: the keys you want to use when recovering the password for an account
    #   * +reset_password_within+: the time period within which the password must be reset or the token expires.
    #   * +sign_in_after_reset_password+: whether or not to sign in the user automatically after a password reset.
    #
    # == Examples
    #
    #   # resets the user password and save the record, true if valid passwords are given, otherwise false
    #   User.find(1).reset_password('password123', 'password123')
    #
    #   # creates a new token and send it with instructions about how to reset the password
    #   User.find(1).send_reset_password_instructions
    #
    module Recoverable
      extend ActiveSupport::Concern

      def self.required_fields(klass)
        [:reset_password_sent_at, :reset_password_token]
      end

      included do
        before_update do
          if (respond_to?(:email_changed?) && email_changed?) || encrypted_password_changed?
            clear_reset_password_token
          end
        end
      end

      # Update password saving the record and clearing token. Returns true if
      # the passwords are valid and the record was saved, false otherwise.
      def reset_password(new_password, new_password_confirmation)
        self.password = new_password
        self.password_confirmation = new_password_confirmation

        if respond_to?(:after_password_reset) && valid?
          ActiveSupport::Deprecation.warn "after_password_reset is deprecated"
          after_password_reset
        end

        save
      end

      def reset_password!(new_password, new_password_confirmation)
        ActiveSupport::Deprecation.warn "reset_password! is deprecated in favor of reset_password"
        reset_password(new_password, new_password_confirmation)
      end

      # Resets reset password token and send reset password instructions by email.
      # Returns the token sent in the e-mail.
      def send_reset_password_instructions
        token = set_reset_password_token
        send_reset_password_instructions_notification(token)

        token
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
        reset_password_sent_at && reset_password_sent_at.utc >= self.class.reset_password_within.ago.utc
      end

      protected

        # Removes reset_password token
        def clear_reset_password_token
          self.reset_password_token = nil
          self.reset_password_sent_at = nil
        end

        def set_reset_password_token
          raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)

          self.reset_password_token   = enc
          self.reset_password_sent_at = Time.now.utc
          self.save(validate: false)
          raw
        end

        def send_reset_password_instructions_notification(token)
          send_devise_notification(:reset_password_instructions, token, {})
        end

      module ClassMethods
        # Attempt to find a user by password reset token. If a user is found, return it
        # If a user is not found, return nil
        def with_reset_password_token(token)
          reset_password_token = Devise.token_generator.digest(self, :reset_password_token, token)
          to_adapter.find_first(reset_password_token: reset_password_token)
        end

        # Attempt to find a user by its email. If a record is found, send new
        # password instructions to it. If user is not found, returns a new user
        # with an email not found error.
        # Attributes must contain the user's email
        def send_reset_password_instructions(attributes={})
          recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
          recoverable.send_reset_password_instructions if recoverable.persisted?
          recoverable
        end

        # Attempt to find a user by its reset_password_token to reset its
        # password. If a user is found and token is still valid, reset its password and automatically
        # try saving the record. If not user is found, returns a new user
        # containing an error in reset_password_token attribute.
        # Attributes must contain reset_password_token, password and confirmation
        def reset_password_by_token(attributes={})
          original_token       = attributes[:reset_password_token]
          reset_password_token = Devise.token_generator.digest(self, :reset_password_token, original_token)

          recoverable = find_or_initialize_with_error_by(:reset_password_token, reset_password_token)

          if recoverable.persisted?
            if recoverable.reset_password_period_valid?
              recoverable.reset_password(attributes[:password], attributes[:password_confirmation])
            else
              recoverable.errors.add(:reset_password_token, :expired)
            end
          end

          recoverable.reset_password_token = original_token if recoverable.reset_password_token.present?
          recoverable
        end

        Devise::Models.config(self, :reset_password_keys, :reset_password_within, :sign_in_after_reset_password)
      end
    end
  end
end
