require 'devise/strategies/rememberable'
require 'devise/hooks/rememberable'

module Devise
  module Models
    # Rememberable manages generating and clearing token for remember the user
    # from a saved cookie. Rememberable also has utility methods for dealing
    # with serializing the user into the cookie and back from the cookie, trying
    # to lookup the record based on the saved information.
    # You probably wouldn't use rememberable methods directly, they are used
    # mostly internally for handling the remember token.
    #
    # Configuration:
    #
    #   remember_for: the time you want the user will be remembered without
    #                 asking for credentials. After this time the user will be
    #                 blocked and will have to enter his credentials again.
    #                 This configuration is also used to calculate the expires
    #                 time for the cookie created to remember the user.
    #                 By default remember_for is 2.weeks.
    #
    # Examples:
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

      def self.included(base)
        base.class_eval do
          extend ClassMethods

          # Remember me option available in after_authentication hook.
          attr_accessor :remember_me
        end
      end

      # Generate a new remember token and save the record without validations.
      def remember_me!
        self.remember_token = Devise.friendly_token
        self.remember_created_at = Time.now.utc
        save(:validate => false)
      end

      # Removes the remember token only if it exists, and save the record
      # without validations.
      def forget_me!
        if remember_token
          self.remember_token = nil
          self.remember_created_at = nil
          save(:validate => false)
        end
      end

      # Checks whether the incoming token matches or not with the record token.
      def valid_remember_token?(token)
        remember_token && !remember_expired? && remember_token == token
      end

      # Remember token should be expired if expiration time not overpass now.
      def remember_expired?
        remember_expires_at <= Time.now.utc
      end

      # Remember token expires at created time + remember_for configuration
      def remember_expires_at
        remember_created_at + self.class.remember_for
      end

      module ClassMethods
        # Create the cookie key using the record id and remember_token
        def serialize_into_cookie(record)
          "#{record.id}::#{record.remember_token}"
        end

        # Recreate the user based on the stored cookie
        def serialize_from_cookie(cookie)
          record_id, record_token = cookie.split('::')
          record = find(:first, :conditions => { :id => record_id }) if record_id
          record if record.try(:valid_remember_token?, record_token)
        end

        Devise::Models.config(self, :remember_for)
      end
    end
  end
end
