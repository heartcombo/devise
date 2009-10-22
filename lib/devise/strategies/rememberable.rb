module Devise
  module Strategies
    # Remember the user through the remember token. This strategy is responsible
    # to verify whether there is a cookie with the remember token, and to
    # recreate the user from this cookie if it exists.  Must be called *before*
    # authenticable.
    class Rememberable < Devise::Strategies::Base

      # A valid strategy for rememberable needs a remember token in the cookies.
      def valid?
        super && remember_me_cookie.present?
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
          cookies['remember_token']
        end
    end
  end
end

Warden::Strategies.add(:rememberable, Devise::Strategies::Rememberable)
