module Devise
  module Authenticable
    require 'digest/sha1'

    # Auth key for encrypting password
    SECURE_AUTH_SITE_KEY = '23c64df433d9b08e464db5c05d1e6202dd2823f0'

    def self.included(base)
      base.class_eval do
        extend ClassMethods

        attr_reader     :password
        attr_accessor   :password_confirmation
        attr_accessible :email, :password, :password_confirmation
      end
    end

    # Defines the new password, generating a salt and encrypting it.
    #
    def password=(new_password)
      if new_password != @password
        @password = new_password
        if @password.present?
          generate_salt
          encrypt_password
        end
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
        self.encrypted_password = password_digest(password)
      end

      # Gererates a default password digest based on salt, SECURE_AUTH_SITE_KEY
      # and the incoming password
      #
      def password_digest(password_to_digest)
        secure_digest(password_salt, SECURE_AUTH_SITE_KEY, password_to_digest)
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
        user = self.find_by_email(email)
        user if user.valid_password?(password) unless user.nil?
      end
    end
  end
end

