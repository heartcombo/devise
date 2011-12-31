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
    #   * +allow_unconfirmed_access_for+: the time you want to allow the user to access his account
    #     before confirming it. After this period, the user access is denied. You can
    #     use this to let your user access some features of your application without
    #     confirming the account, but blocking it after a certain period (ie 7 days).
    #     By default allow_unconfirmed_access_for is zero, it means users always have to confirm to sign in.
    #   * +reconfirmable+: requires any email changes to be confirmed (exactly the same way as
    #     initial account confirmation) to be applied. Requires additional unconfirmed_email
    #     db field to be setup (t.reconfirmable in migrations). Until confirmed new email is
    #     stored in unconfirmed email column, and copied to email column on successful
    #     confirmation.
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
        before_update :postpone_email_change_until_confirmation, :if => :postpone_email_change?
        after_update :send_confirmation_instructions, :if => :reconfirmation_required?
      end

      # Confirm a user by setting it's confirmed_at to actual time. If the user
      # is already confirmed, add an error to email field. If the user is invalid
      # add errors
      def confirm!
        pending_any_confirmation do
          self.confirmation_token = nil
          self.confirmed_at = Time.now.utc

          if self.class.reconfirmable && unconfirmed_email.present?
            @bypass_postpone = true
            self.email = unconfirmed_email
            self.unconfirmed_email = nil

            # We need to validate in such cases to enforce e-mail uniqueness
            save(:validate => true)
          else
            save(:validate => false)
          end
        end
      end

      # Verifies whether a user is confirmed or not
      def confirmed?
        !!confirmed_at
      end

      def pending_reconfirmation?
        self.class.reconfirmable && unconfirmed_email.present?
      end

      # Send confirmation instructions by email
      def send_confirmation_instructions
        self.confirmation_token = nil if reconfirmation_required?
        @reconfirmation_required = false

        generate_confirmation_token! if self.confirmation_token.blank?
        self.devise_mailer.confirmation_instructions(self).deliver
      end

      # Resend confirmation token. This method does not need to generate a new token.
      def resend_confirmation_token
        pending_any_confirmation { send_confirmation_instructions }
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

      def headers_for(action)
        headers = super
        if action == :confirmation_instructions && pending_reconfirmation?
          headers[:to] = unconfirmed_email
        end
        headers
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
        #   # allow_unconfirmed_access_for = 1.day and confirmation_sent_at = today
        #   confirmation_period_valid?   # returns true
        #
        #   # allow_unconfirmed_access_for = 5.days and confirmation_sent_at = 4.days.ago
        #   confirmation_period_valid?   # returns true
        #
        #   # allow_unconfirmed_access_for = 5.days and confirmation_sent_at = 5.days.ago
        #   confirmation_period_valid?   # returns false
        #
        #   # allow_unconfirmed_access_for = 0.days
        #   confirmation_period_valid?   # will always return false
        #
        def confirmation_period_valid?
          confirmation_sent_at && confirmation_sent_at.utc >= self.class.allow_unconfirmed_access_for.ago
        end

        # Checks whether the record requires any confirmation.
        def pending_any_confirmation
          if !confirmed? || pending_reconfirmation?
            yield
          else
            self.errors.add(:email, :already_confirmed)
            false
          end
        end

        # Generates a new random token for confirmation, and stores the time
        # this token is being generated
        def generate_confirmation_token
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

        def postpone_email_change_until_confirmation
          @reconfirmation_required = true
          self.unconfirmed_email = self.email
          self.email = self.email_was
        end

        def postpone_email_change?
          postpone = self.class.reconfirmable && email_changed? && !@bypass_postpone
          @bypass_postpone = nil
          postpone
        end

        def reconfirmation_required?
          self.class.reconfirmable && @reconfirmation_required
        end

      module ClassMethods
        # Attempt to find a user by its email. If a record is found, send new
        # confirmation instructions to it. If not, try searching for a user by unconfirmed_email
        # field. If no user is found, returns a new user with an email not found error.
        # Options must contain the user email
        def send_confirmation_instructions(attributes={})
          confirmable = find_by_unconfirmed_email_with_errors(attributes) if reconfirmable
          unless confirmable.try(:persisted?)
            confirmable = find_or_initialize_with_errors(confirmation_keys, attributes, :not_found)
          end
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

        # Find a record for confirmation by unconfirmed email field
        def find_by_unconfirmed_email_with_errors(attributes = {})
          unconfirmed_required_attributes = confirmation_keys.map { |k| k == :email ? :unconfirmed_email : k }
          unconfirmed_attributes = attributes.symbolize_keys
          unconfirmed_attributes[:unconfirmed_email] = unconfirmed_attributes.delete(:email)
          find_or_initialize_with_errors(unconfirmed_required_attributes, unconfirmed_attributes, :not_found)
        end

        Devise::Models.config(self, :allow_unconfirmed_access_for, :confirmation_keys, :reconfirmable)
      end
    end
  end
end
