# frozen_string_literal: true

require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    # Default strategy for signing in a user, based on their email and password in the database.
    class DatabaseAuthenticatable < Authenticatable
      NULL_BYTE = "\0"
      private_constant :NULL_BYTE

      def authenticate!
        return fail!(:invalid) if includes_null_byte?([password, *authentication_hash.values])

        resource  = password.present? && mapping.to.find_for_database_authentication(authentication_hash)
        hashed = false

        if validate(resource){ hashed = true; resource.valid_password?(password) }
          remember_me(resource)
          resource.after_database_authentication
          success!(resource)
        end

        # In paranoid mode, hash the password even when a resource doesn't exist for the given authentication key.
        # This is necessary to prevent enumeration attacks - e.g. the request is faster when a resource doesn't
        # exist in the database if the password hashing algorithm is not called.
        mapping.to.new.password = password if !hashed && Devise.paranoid
        unless resource
          Devise.paranoid ? fail(:invalid) : fail(:not_found_in_database)
        end
      end

    private

      def includes_null_byte?(values)
        values.any? { |value| value.to_s.include?(NULL_BYTE) }
      end
    end
  end
end

Warden::Strategies.add(:database_authenticatable, Devise::Strategies::DatabaseAuthenticatable)
