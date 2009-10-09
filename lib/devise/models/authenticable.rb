module Devise
  module Models
    module Authenticable
      require 'digest/sha1'

      mattr_accessor :pepper, :stretches
      # Pepper for encrypting password
      self.pepper = '23c64df433d9b08e464db5c05d1e6202dd2823f0'
      # Encrypt password as many times as possible
      self.stretches = 10

      def self.included(base)
        base.class_eval do
          extend ClassMethods

          before_save :generate_salt
          before_save :encrypt_password

          attr_accessor   :password, :password_confirmation
          attr_accessible :email, :password, :password_confirmation
        end
      end

      # Verifies whether an incoming_password (ie from login) is the user password
      #
      def valid_password?(incoming_password)
        password_digest(incoming_password) == encrypted_password
      end

      private

        # Generate password salt using SHA1 based on password and Time.now
        #
        def generate_salt
          self.password_salt = secure_digest(Time.now.utc, random_string, password) if password_salt.blank?
        end

        # Encrypt password using SHA1
        #
        def encrypt_password
          self.encrypted_password = password_digest(password) unless password.blank?
        end

        # Gererates a default password digest based on salt, pepper and the
        # incoming password
        #
        def password_digest(password_to_digest)
          digest = pepper
          stretches.times { digest = secure_digest(password_salt, digest, password_to_digest, pepper)}
          digest
        end

        # Generate a SHA1 digest joining args. Generated token is something like
        #
        #   --arg1--arg2--arg3--argN--
        #
        def secure_digest(*tokens)
          ::Digest::SHA1.hexdigest('--' << tokens.flatten.join('--') << '--')
        end

        # Generate a string randomically based on rand method
        #
        def random_string
          (1..10).map{ rand.to_s }
        end

      module ClassMethods

        # Authenticate a user based on email and password. Returns the
        # authenticated user if it's valid or nil
        #
        def authenticate(email, password)
          authenticable = self.find_by_email(email)
          authenticable if authenticable.valid_password?(password) unless authenticable.nil?
        end
      end
    end
  end
end
