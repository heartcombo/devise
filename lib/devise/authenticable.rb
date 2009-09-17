module Devise
  module Authenticable
    require 'digest/sha1'

    # Password digest config
    # Auth key for encrypting password
    SECURE_AUTH_SITE_KEY         = '23c64df433d9b08e464db5c05d1e6202dd2823f0'
    # Times digest will be applied to crypted password
    SECURE_AUTH_DIGEST_STRETCHES = 10

    def self.included(base)
      base.class_eval do
        #attr_accessor :password, :password_confirmation
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

    private

      # Generate password salt using SHA1 based on password and Time.now
      #
      def generate_salt
        self.password_salt = secure_digest(Time.now.utc, password) if password_salt.blank?
      end

      # Encrypt password using SHA1 based on salt, password and SECURE_AUTH_SITE_KEY
      #
      def encrypt_password
        self.encrypted_password = secure_digest(password_salt, SECURE_AUTH_SITE_KEY, password)
      end

      # Generate a SHA1 digest joining args. Generated token is something like
      #
      #   --arg1--arg2--arg3--argN--
      #
      def secure_digest(*tokens)
        ::Digest::SHA1.hexdigest('--' << tokens.flatten.join('--') << '--')
      end
  end
end

