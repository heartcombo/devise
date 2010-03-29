require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    # Default strategy for signing in a user, based on his email and password in the database.
    class DatabaseAuthenticatable < Authenticatable
      def authenticate!
        resource = mapping.to.find_for_database_authentication(authentication_hash)

        if validate(resource){ resource.valid_password?(password) }
          success!(resource)
        else
          fail(:invalid)
        end
      end
    end
  end
end

Warden::Strategies.add(:database_authenticatable, Devise::Strategies::DatabaseAuthenticatable)
