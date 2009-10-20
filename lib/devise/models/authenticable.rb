require 'digest/sha1'

module Devise
  module Models

    # Authenticable Module, responsible for encrypting password and validating
    # authenticity of a user while signing in.
    #
    # Configuration:
    #   pepper: encryption key used for creating encrypted password. Each time
    #           password changes, it's gonna be encrypted again, and this key
    #           is added to the password and salt to create a secure hash.
    #     def pepper; '1234567890987654321'; end
    #
    #   stretches: defines how many times the password will be encrypted.
    #     def stretches; 20; end
    #
    # Examples:
    #
    #    User.authenticate('email@test.com', 'password123')  # returns authenticated user or nil
    #    User.find(1).valid_password?('password123')         # returns true/false
    module Authenticable
      mattr_accessor :pepper, :stretches

      def self.included(base)
        base.class_eval do
          extend ClassMethods

          attr_reader :password
          attr_accessor :password_confirmation
          attr_accessible :email, :password, :password_confirmation
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

        # Pepper for encrypting password. Fallback to default configuration if
        # no one exists for this specific model. Overwrite inside your model
        # to provide specific pepper configuration:
        #
        #   def pepper; 'my_pepper_123'; end
        def pepper
          @pepper ||= Devise.pepper
        end

        # Encrypt password as many times as possible. Fallback to default
        # configuration if no one exists for this specific model.
        #
        #   def stretches; 20; end
        def stretches
          @stretches ||= Devise.stretches
        end

        # Gererates a default password digest based on salt, pepper and the
        # incoming password.
        def password_digest(password_to_digest)
          digest = pepper
          stretches.times { digest = secure_digest(password_salt, digest, password_to_digest, pepper) }
          digest
        end

        # Generate a SHA1 digest joining args. Generated token is something like
        #
        #   --arg1--arg2--arg3--argN--
        def secure_digest(*tokens)
          ::Digest::SHA1.hexdigest('--' << tokens.flatten.join('--') << '--')
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
          authenticable = find_by_email(attributes[:email])
          authenticable if authenticable.try(:valid_password?, attributes[:password])
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
      end
    end
  end
end
