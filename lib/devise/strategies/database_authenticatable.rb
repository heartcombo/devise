require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    # Default strategy for signing in a user, based on their email and password in the database.
    class DatabaseAuthenticatable < Authenticatable
      def authenticate!
        resource  = valid_password? && mapping.to.find_for_database_authentication(authentication_hash)
        encrypted = false

        if validate(resource){ encrypted = true; resource.valid_password?(password) }
          remember_me(resource)
          resource.after_database_authentication
          success!(resource)
        end

        mapping.to.new.password = password if !encrypted && Devise.paranoid
        fail(:not_found_in_database) unless resource
      end
    end
  end
end

Warden::Strategies.add(:database_authenticatable, Devise::Strategies::DatabaseAuthenticatable)
