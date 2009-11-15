require 'devise/strategies/authenticatable'
require 'devise/serializers/authenticatable'

module Devise
  module Models

    # Authenticable Module, responsible for encrypting password and validating
    # authenticity of a user while signing in.
    #
    # Configuration:
    #
    # You can overwrite configuration values by setting in globally in Devise,
    # using devise method or overwriting the respective instance method.
    #
    #   pepper: encryption key used for creating encrypted password. Each time
    #           password changes, it's gonna be encrypted again, and this key
    #           is added to the password and salt to create a secure hash.
    #           Always use `rake secret' to generate a new key.
    #
    #   stretches: defines how many times the password will be encrypted.
    #
    #   encryptor: the encryptor going to be used. By default :sha1.
    #
    #   authentication_keys: parameters used for authentication. By default [:email]
    #
    # Examples:
    #
    #    User.authenticate('email@test.com', 'password123')  # returns authenticated user or nil
    #    User.find(1).valid_password?('password123')         # returns true/false
    #
    module Authenticatable
      def self.included(base)
        base.class_eval do
          extend ClassMethods

          attr_reader :password
          attr_accessor :password_confirmation
        end
      end

      # Regenerates password salt and encrypted password each time password is
      # setted.
      def password=(new_password)
        @password = new_password
        self.password_salt = friendly_token
        self.encrypted_password = password_digest(@password)
      end

      # Verifies whether an incoming_password (ie from login) is the user
      # password.
      def valid_password?(incoming_password)
        password_digest(incoming_password) == encrypted_password
      end

      protected
      
        # Digests the password using the configured encryptor
        def password_digest(password)
          encryptor.digest(password, stretches, password_salt, pepper)
        end
      
        # Generate a friendly string randomically to be used as token.
        def friendly_token
          ActiveSupport::SecureRandom.base64(15).tr('+/=', '-_ ').strip.delete("\n")
        end

      module ClassMethods
        # Authenticate a user based on email and password. Returns the
        # authenticated user if it's valid or nil.
        # Attributes are :email and :password
        def authenticate(attributes={})
          return unless authentication_keys.all? { |k| attributes[k].present? }
          conditions = attributes.slice(*authentication_keys)
          authenticatable = find(:first, :conditions => conditions)
          authenticatable if authenticatable.try(:valid_password?, attributes[:password])
        end

        # Attempt to find a user by it's email. If not user is found, returns a
        # new user with an email not found error.
        def find_or_initialize_with_error_by_email(email)
          perishable = find_or_initialize_by_email(email)
          if perishable.new_record?
            perishable.errors.add(:email, :not_found, :default => 'not found')
          end
          perishable
        end

        # Hook to serialize user into session. Overwrite if you want.
        def serialize_into_session(record)
          [record.class, record.id]
        end

        # Hook to serialize user from session. Overwrite if you want.
        def serialize_from_session(keys)
          klass, id = keys
          raise "#{self} cannot serialize from #{klass} session since it's not its ancestors" unless klass <= self 
          klass.find_by_id(id)
        end
      end

      Devise::Models.config(self, :pepper, :stretches, :encryptor, :authentication_keys)
    end
  end
end
