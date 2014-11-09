require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    # Remember the user through the remember token. This strategy is responsible
    # to verify whether there is a cookie with the remember token, and to
    # recreate the user from this cookie if it exists. Must be called *before*
    # authenticatable.
    class Rememberable < Authenticatable
      # A valid strategy for rememberable needs a remember token in the cookies.
      def valid?
        @remember_cookie = nil
        remember_cookie.present?
      end

      # To authenticate a user we deserialize the cookie and attempt finding
      # the record in the database. If the attempt fails, we pass to another
      # strategy handle the authentication.
      def authenticate!
        resource = mapping.to.serialize_from_cookie(*remember_cookie)

        unless resource
          cookies.delete(remember_key)
          return pass
        end

        if validate(resource)
          remember_me(resource)
          extend_remember_me_period(resource)
          resource.after_remembered
          success!(resource)
        end
      end

    private

      def extend_remember_me_period(resource)
        if resource.respond_to?(:extend_remember_period=)
          resource.extend_remember_period = mapping.to.extend_remember_period
        end
      end

      def remember_me?
        true
      end

      def remember_key
        mapping.to.rememberable_options.fetch(:key, "remember_#{scope}_token")
      end

      def remember_cookie
        @remember_cookie ||= cookies.signed[remember_key]
      end

    end
  end
end

Warden::Strategies.add(:rememberable, Devise::Strategies::Rememberable)
