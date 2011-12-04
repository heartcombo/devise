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
    #     will have to enter his credentials again. This configuration is also
    #     used to calculate the expires time for the cookie created to remember
    #     the user. By default remember_for is 2.weeks.
    #
    #   * +extend_remember_period+: if true, extends the user's remember period
    #     when remembered via cookie. False by default.
    #
    #   * +cookie_options+: configuration options passed to the created cookie.
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

      # Generate a new remember token and save the record without validations
      # unless remember_across_browsers is true and the user already has a valid token.
      def remember_me!(extend_period=false)
        self.remember_created_at = Time.now.utc if generate_remember_timestamp?(extend_period)
        save(:validate => false)
      end

      # If the record is persisted, remove the remember token (but only if
      # it exists), and save the record without validations.
      def forget_me!
        if persisted?
          self.remember_token = nil if respond_to?(:remember_token=)
          self.remember_created_at = nil
          save(:validate => false)
        end
      end

      # Remember token should be expired if expiration time not overpass now.
      def remember_expired?
        remember_created_at.nil? || (remember_expires_at <= Time.now.utc)
      end

      # Remember token expires at created time + remember_for configuration
      def remember_expires_at
        remember_created_at + self.class.remember_for
      end

      def rememberable_value
        if respond_to?(:authenticatable_salt) && (salt = authenticatable_salt)
          salt
        else
          raise "The #{self.class.name} class does not respond to remember_token and " <<
            "authenticatable_salt returns nil. In order to use rememberable, you must " <<
            "add a remember_token field to your model or ensure a password is always set."
        end
      end

      def cookie_options
        self.class.cookie_options
      end

    protected

      # Generate a timestamp if extend_remember_period is true, if no remember_token
      # exists, or if an existing remember token has expired.
      def generate_remember_timestamp?(extend_period) #:nodoc:
        extend_period || remember_created_at.nil? || remember_expired?
      end

      module ClassMethods
        # Create the cookie key using the record id and remember_token
        def serialize_into_cookie(record)
          [record.to_key, record.rememberable_value]
        end

        # Recreate the user based on the stored cookie
        def serialize_from_cookie(id, remember_token)
          record = to_adapter.get(id)
          record if record && record.rememberable_value == remember_token && !record.remember_expired?
        end

        # Generate a token checking if one does not already exist in the database.
        def remember_token
          generate_token(:remember_token)
        end

        Devise::Models.config(self, :remember_for, :extend_remember_period, :cookie_options)
      end
    end
  end
end
