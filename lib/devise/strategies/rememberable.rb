require 'devise/strategies/base'
require 'devise/hooks/rememberable'

module Devise
  module Strategies
    # Remember the user through the remember token. This strategy is responsible
    # to verify whether there is a cookie with the remember token, and to
    # recreate the user from this cookie if it exists. Must be called *before*
    # authenticatable.
    class Rememberable < Devise::Strategies::Base
      include Devise::Hooks::Rememberable

      # A valid strategy for rememberable needs a remember token in the cookies.
      def valid?
        remember_cookie.present?
      end

      # To authenticate a user we deserialize the cookie and attempt finding
      # the record in the database. If the attempt fails, we pass to another
      # strategy handle the authentication.
      def authenticate!
        resource = mapping.to.serialize_from_cookie(*remember_cookie)

        if validate(resource)
          success!(resource)
        else
          cookies.delete(remember_key)
          pass
        end
      end

    private

      def remember_me?
        true
      end

      def remember_key
        "remember_#{scope}_token"
      end

      # Accessor for remember cookie
      def remember_cookie
        @remember_cookie ||= cookies.signed[remember_key]
      end
    end
  end
end

Warden::Strategies.add(:rememberable, Devise::Strategies::Rememberable)