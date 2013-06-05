require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    # Default strategy for signing in a user, based on his email and password in the database.
    class DatabaseAuthenticatable < Authenticatable
      def authenticate!
        logger.debug("Performing authentication with the DatabaseAuthenticatable strategy...")
        resource = valid_password? && mapping.to.find_for_database_authentication(authentication_hash)

        if validate(resource){ resource.valid_password?(password) }
          logger.debug("DatabaseAuthenticatable strategy validated the password successfully.")
          resource.after_database_authentication
          logger.debug("Authentication with the DatabaseAuthenticatable strategy succeeded.")
          success!(resource)
        elsif !halted?
          logger.debug("Authentication with the DatabaseAuthenticatable strategy failed.")
          fail(:invalid)
        end
      end
    end
  end
end

Warden::Strategies.add(:database_authenticatable, Devise::Strategies::DatabaseAuthenticatable)
