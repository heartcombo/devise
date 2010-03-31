require 'devise/strategies/base'

module Devise
  module Strategies
    # Remember the user through the remember token. This strategy is responsible
    # to verify whether there is a cookie with the remember token, and to
    # recreate the user from this cookie if it exists.  Must be called *before*
    # authenticatable.
    class Rememberable < Devise::Strategies::Base

      # A valid strategy for rememberable needs a remember token in the cookies.
      def valid?
        remember_cookie.present?
      end

      # To authenticate a user we deserialize the cookie and attempt finding
      # the record in the database. If the attempt fails, we pass to another
      # strategy handle the authentication.
      def authenticate!
        if resource = mapping.to.serialize_from_cookie(*remember_cookie)
          success!(resource)
        else
          cookies.delete(remember_key)
          pass
        end
      end

    private

      def remember_key
        "remember_#{mapping.name}_token"
      end

      # Accessor for remember cookie
      def remember_cookie
        @remember_cookie ||= cookies.signed[remember_key]
      end
    end
  end
end

Warden::Strategies.add(:rememberable, Devise::Strategies::Rememberable)