module Devise
  module Models
    # Confirmable is responsible to verify if an account is already confirmed to
    # sign in, and to send emails with confirmation instructions.
    # Confirmation instructions are sent to the user email after creating a
    # record and when manually requested by a new confirmation instruction request.
    #
    # == Options
    #
    # Confirmable adds the following options to devise_for:
    #
    #   * +confirm_within+: the time you want to allow the user to access his account
    #     before confirming it. After this period, the user access is denied. You can
    #     use this to let your user access some features of your application without
    #     confirming the account, but blocking it after a certain period (ie 7 days).
    #     By default confirm_within is zero, it means users always have to confirm to sign in.
    #
    # == Examples
    #
    #   User.find(1).confirm!      # returns true unless it's already confirmed
    #   User.find(1).confirmed?    # true/false
    #   User.find(1).send_confirmation_instructions # manually send instructions
    #
    module Confirmable
      extend ActiveSupport::Concern

      included do
        before_create :generate_confirmation_token, :if => :confirmation_required?
        after_create  :send_confirmation_instructions, :if => :confirmation_required?
      end

      # Confirm a user by setting its confirmed_at to actual time. If the user
      # is already confirmed, add en error to email field
      def confirm!
        unless_confirmed do
          self.confirmation_token = nil
          self.confirmed_at = Time.now.utc
          save(:validate => false)
        end
      end

      # Verifies whether a user is confirmed or not
      def confirmed?
        !!confirmed_at
      end

      # Send confirmation instructions by email
      def send_confirmation_instructions
        generate_confirmation_token! if self.confirmation_token.nil?
        self.devise_mailer.confirmation_instructions(self).deliver
      end

      # Resend confirmation token. This method does not need to generate a new token.
      def resend_confirmation_token
        unless_confirmed { send_confirmation_instructions }
      end

      # Overwrites active_for_authentication? for confirmation
      # by verifying whether a user is active to sign in or not. If the user
      # is already confirmed, it should never be blocked. Otherwise we need to
      # calculate if the confirm time has not expired for this user.
      def active_for_authentication?
        super && (!confirmation_required? || confirmed? || confirmation_period_valid?)
      end

      # The message to be shown if the account is inactive.
      def inactive_message
        !confirmed? ? :unconfirmed : super
      end

      # If you don't want confirmation to be sent on create, neither a code
      # to be generated, call skip_confirmation!
      def skip_confirmation!
        self.confirmed_at = Time.now.utc
      end

      protected

        # Callback to overwrite if confirmation is required or not.
        def confirmation_required?
          !confirmed?
        end

        # Checks if the confirmation for the user is within the limit time.
        # We do this by calculating if the difference between today and the
        # confirmation sent date does not exceed the confirm in time configured.
        # Confirm_within is a model configuration, must always be an integer value.
        #
        # Example:
        #
        #   # confirm_within = 1.day and confirmation_sent_at = today
        #   confirmation_period_valid?   # returns true
        #
        #   # confirm_within = 5.days and confirmation_sent_at = 4.days.ago
        #   confirmation_period_valid?   # returns true
        #
        #   # confirm_within = 5.days and confirmation_sent_at = 5.days.ago
        #   confirmation_period_valid?   # returns false
        #
        #   # confirm_within = 0.days
        #   confirmation_period_valid?   # will always return false
        #
        def confirmation_period_valid?
          confirmation_sent_at && confirmation_sent_at.utc >= self.class.confirm_within.ago
        end

        # Checks whether the record is confirmed or not, yielding to the block
        # if it's already confirmed, otherwise adds an error to email.
        def unless_confirmed
          unless confirmed?
            yield
          else
            self.errors.add(:email, :already_confirmed)
            false
          end
        end

        # Generates a new random token for confirmation, and stores the time
        # this token is being generated
        def generate_confirmation_token
          self.confirmed_at = nil
          self.confirmation_token = self.class.confirmation_token
          self.confirmation_sent_at = Time.now.utc
        end

        def generate_confirmation_token!
          generate_confirmation_token && save(:validate => false)
        end

        def after_password_reset
          super
          confirm! unless confirmed?
        end

      module ClassMethods
        # Attempt to find a user by its email. If a record is found, send new
        # confirmation instructions to it. If not user is found, returns a new user
        # with an email not found error.
        # Options must contain the user email
        def send_confirmation_instructions(attributes={})
          confirmable = find_or_initialize_with_errors(confirmation_keys, attributes, :not_found)
          confirmable.resend_confirmation_token if confirmable.persisted?
          confirmable
        end

        # Find a user by its confirmation token and try to confirm it.
        # If no user is found, returns a new user with an error.
        # If the user is already confirmed, create an error for the user
        # Options must have the confirmation_token
        def confirm_by_token(confirmation_token)
          confirmable = find_or_initialize_with_error_by(:confirmation_token, confirmation_token)
          confirmable.confirm! if confirmable.persisted?
          confirmable
        end

        # Generate a token checking if one does not already exist in the database.
        def confirmation_token
          generate_token(:confirmation_token)
        end

        Devise::Models.config(self, :confirm_within, :confirmation_keys)
      end
    end
  end
end
