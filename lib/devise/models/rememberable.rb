require 'devise/strategies/rememberable'
require 'devise/hooks/rememberable'
require 'devise/hooks/forgetable'

module Devise
  module Models
    # Rememberable manages generating and clearing token for remember the user
    # from a saved cookie. Rememberable also has utility methods for dealing
    # with serializing the user into the cookie and back from the cookie, trying
    # to lookup the record based on the saved information.
    # You probably wouldn't use rememberable methods directly, they are used
    # mostly internally for handling the remember token.
    #
    # == Options
    #
    # Rememberable adds the following options in devise_for:
    #
    #   * +remember_for+: the time you want the user will be remembered without
    #     asking for credentials. After this time the user will be blocked and
    #     will have to enter their credentials again. This configuration is also
    #     used to calculate the expires time for the cookie created to remember
    #     the user. By default remember_for is 2.weeks.
    #
    #   * +extend_remember_period+: if true, extends the user's remember period
    #     when remembered via cookie. False by default.
    #
    #   * +rememberable_options+: configuration options passed to the created cookie.
    #
    # == Examples
    #
    #   User.find(1).remember_me!  # regenerating the token
    #   User.find(1).forget_me!    # clearing the token
    #
    #   # generating info to put into cookies
    #   User.serialize_into_cookie(user)
    #
    #   # lookup the user based on the incoming cookie information
    #   User.serialize_from_cookie(cookie_string)
    module Rememberable
      extend ActiveSupport::Concern

      attr_accessor :remember_me, :extend_remember_period

      def self.required_fields(klass)
        [:remember_created_at]
      end

      # TODO: We were used to receive a extend period argument but we no longer do.
      # Remove this for Devise 4.0.
      def remember_me!(*)
        self.remember_token = self.class.remember_token if respond_to?(:remember_token)
        self.remember_created_at ||= Time.now.utc
        save(validate: false) if self.changed?
      end

      # If the record is persisted, remove the remember token (but only if
      # it exists), and save the record without validations.
      def forget_me!
        return unless persisted?
        self.remember_token = nil if respond_to?(:remember_token)
        self.remember_created_at = nil if self.class.expire_all_remember_me_on_sign_out
        save(validate: false)
      end

      # Remember token should be expired if expiration time not overpass now.
      def remember_expired?
        remember_created_at.nil?
      end

      def remember_expires_at
        self.class.remember_for.from_now
      end

      def rememberable_value
        if respond_to?(:remember_token)
          remember_token
        elsif respond_to?(:authenticatable_salt) && (salt = authenticatable_salt.presence)
          salt
        else
          raise "authenticable_salt returned nil for the #{self.class.name} model. " \
            "In order to use rememberable, you must ensure a password is always set " \
            "or have a remember_token column in your model or implement your own " \
            "rememberable_value in the model with custom logic."
        end
      end

      def rememberable_options
        self.class.rememberable_options
      end

      # A callback initiated after successfully being remembered. This can be
      # used to insert your own logic that is only run after the user is
      # remembered.
      #
      # Example:
      #
      #   def after_remembered
      #     self.update_attribute(:invite_code, nil)
      #   end
      #
      def after_remembered
      end


      module ClassMethods
        # Create the cookie key using the record id and remember_token
        def serialize_into_cookie(record)
          [record.to_key, record.rememberable_value, Time.now.utc]
        end

        # Recreate the user based on the stored cookie
        def serialize_from_cookie(*args)
          serialize_from_cookie_with_or_without_record(nil, args)
        end

        # Check if the given record is the one serialized in cookie
        def serialized_in_cookie?(record, *args)
          !!serialize_from_cookie_with_or_without_record(record, args)
        end

        # Generate a token checking if one does not already exist in the database.
        def remember_token #:nodoc:
          loop do
            token = Devise.friendly_token
            break token unless to_adapter.find_first({ remember_token: token })
          end
        end

        private

        def serialize_from_cookie_with_or_without_record(record, args)
          id, token, generated_at = args
          generated_at = Time.parse(generated_at) rescue nil if generated_at.is_a?(String)

          # The token is only valid if:
          # 1. we have a date
          # 2. the current time does not pass the expiry period
          # 3. there is a record with the given id
          # 4. the record has a remember_created_at date
          # 5. the token date is bigger than the remember_created_at
          # 6. the token matches
          if generated_at.is_a?(Time) &&
             (self.remember_for.ago < generated_at) &&
             (record ||= to_adapter.get(id)) && (id == record.to_key) &&
             (generated_at > (record.remember_created_at || Time.now).utc) &&
             Devise.secure_compare(record.rememberable_value, token)
            record
          end
        end


        # TODO: extend_remember_period is no longer used
        Devise::Models.config(self, :remember_for, :extend_remember_period, :rememberable_options, :expire_all_remember_me_on_sign_out)
      end
    end
  end
end
