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
    # Configuration:
    #
    #   remember_for: the time you want the user will be remembered without
    #                 asking for credentials. After this time the user will be
    #                 blocked and will have to enter his credentials again.
    #                 This configuration is also used to calculate the expires
    #                 time for the cookie created to remember the user.
    #                 2.weeks by default.
    #
    #   remember_across_browsers: if true, a valid remember token can be
    #                             re-used between multiple browsers.
    #                             True by default.
    #
    #   extend_remember_period: if true, extends the user's remember period
    #                           when remembered via cookie.
    #                           False by default.
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
      extend ActiveSupport::Concern

      included do
        # Remember me option available in after_authentication hook.
        attr_accessor :remember_me
      end

      # Generate a new remember token and save the record without validations
      # unless remember_across_browsers is true and the user already has a valid token.
      def remember_me!
        self.remember_token = self.class.remember_token if generate_remember_token?
        self.remember_created_at = Time.now.utc if generate_remember_timestamp?
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

      # Remember token should be expired if expiration time not overpass now.
      def remember_expired?
        remember_created_at && (remember_expires_at <= Time.now.utc)
      end

      # Remember token expires at created time + remember_for configuration
      def remember_expires_at
        remember_created_at + self.class.remember_for
      end

      def cookie_domain
        self.class.cookie_domain
      end

      def cookie_domain?
        self.class.cookie_domain != false
      end

    protected

      # Generate a token unless remember_across_browsers is true and there is
      # an existing remember_token or the existing remember_token has expried.
      def generate_remember_token? #:nodoc:
        !(self.class.remember_across_browsers && remember_token) || remember_expired?
      end

      # Generate a timestamp if extend_remember_period is true, if no remember_token
      # exists, or if an existing remember token has expired.
      def generate_remember_timestamp? #:nodoc:
        self.class.extend_remember_period || remember_created_at.nil? || remember_expired?
      end

      module ClassMethods
        # Create the cookie key using the record id and remember_token
        def serialize_into_cookie(record)
          [record.id, record.remember_token]
        end

        # Recreate the user based on the stored cookie
        def serialize_from_cookie(id, remember_token)
          conditions = { :id => id, :remember_token => remember_token }
          record = find(:first, :conditions => conditions)
          record if record && !record.remember_expired?
        end

        # Generate a token checking if one does not already exist in the database.
        def remember_token
          generate_token(:remember_token)
        end

        Devise::Models.config(self, :remember_for, :remember_across_browsers,
          :extend_remember_period, :cookie_domain)
      end
    end
  end
end
