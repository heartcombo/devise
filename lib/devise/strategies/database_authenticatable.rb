require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    # Default strategy for signing in a user, based on his email and password in the database.
    class DatabaseAuthenticatable < Authenticatable
      def authenticate!
        resource = valid_password? && mapping.to.find_for_database_authentication(authentication_hash)

        if validate(resource){ resource.valid_password?(password) }
          resource.after_database_authentication
          success!(resource)
        else
          fail(I18n.t('devise.failure.invalid'))
        end
      end
    end
  end
end

Warden::Strategies.add(:database_authenticatable, Devise::Strategies::DatabaseAuthenticatable)
