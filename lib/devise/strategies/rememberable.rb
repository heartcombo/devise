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
        remember_me_cookie.present? && mapping.to.respond_to?(:serialize_from_cookie)
      end

      # To authenticate a user we deserialize the cookie and attempt finding
      # the record in the database. If the attempt fails, we pass to another
      # strategy handle the authentication.
      def authenticate!
        if resource = mapping.to.serialize_from_cookie(remember_me_cookie)
          success!(resource)
        else
          pass
        end
      end

    private

      # Accessor for remember cookie
      def remember_me_cookie
        @remember_me_cookie ||= request.cookies["remember_#{mapping.name}_token"]
      end
    end
  end
end

Warden::Strategies.add(:rememberable, Devise::Strategies::Rememberable)