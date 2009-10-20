require 'digest/sha1'

module Devise
  module Models

    # Rememberable manages generating and clearing token for remember the user
    # from a saved cookie. Rememberable also has utility methods for dealing
    # with serializing the user into the cookie and back from the cookie, trying
    # to lookup the record based on the saved information.
    # You probably wouldn't use rememberable methods directly, they are used
    # mostly internally for handling the remember token.
    # Examples:
    #
    #   User.find(1).remember_me!  # regenerating the token
    #   User.find(1).forget_me!    # clearing the token
    #   # generating info to put into cookies
    #   User.serialize_into_cookie(user)
    #   # lookup the user based on the incoming cookie information
    #   User.serialize_from_cookie(cookie_string)
    module Rememberable

      def self.included(base)
        base.class_eval do
          extend ClassMethods

          # Remember me option available in after_authentication hook.
          attr_accessor :remember_me
          attr_accessible :remember_me
        end
      end

      # Generate a new remember token and save the record without validations.
      def remember_me!
        self.remember_token = friendly_token
        save(false)
      end

      # Removes the remember token only if it exists, and save the record
      # without validations.
      def forget_me!
        if remember_token?
          self.remember_token = nil
          save(false)
        end
      end

      # Checks whether the incoming token matches or not with the record token.
      def valid_remember_token?(token)
        remember_token.present? && remember_token == token
      end

      module ClassMethods

        # Attempts to remember the user through it's id and remember_token.
        # Returns the user if one is found and the token is valid, otherwise nil.
        # Attributes must contain :id and :remember_token
        def remember_me!(attributes={})
          rememberable = find_by_id(attributes[:id])
          rememberable if rememberable.try(:valid_remember_token?, attributes[:remember_token])
        end

        # Create the cookie key using the record id and remember_token
        def serialize_into_cookie(record)
          "#{record.id}::#{record.remember_token}"
        end

        # Recreate the user based on the stored cookie
        def serialize_from_cookie(cookie)
          record_id, remember_token = cookie.split('::')
          remember_me!(:id => record_id, :remember_token => remember_token)
        end
      end
    end
  end
end
