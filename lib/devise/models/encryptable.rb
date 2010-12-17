require 'devise/strategies/database_authenticatable'

module Devise
  module Models
    # Encryptable Module adds support to several encryptors.
    #
    # == Options
    #
    # Encryptable adds the following options to devise_for:
    #
    #   * +pepper+: a random string used to provide a more secure hash.
    #
    #   * +encryptor+: the encryptor going to be used. By default is nil.
    #
    # == Examples
    #
    #    User.find(1).valid_password?('password123') # returns true/false
    #
    module Encryptable
      extend ActiveSupport::Concern

      included do
        attr_reader :password, :current_password
        attr_accessor :password_confirmation
      end

      # Generates password salt.
      def password=(new_password)
        if new_password.present?
          self.password_salt = self.class.password_salt
        elsif self.class.password_allow_blank
          self.password_salt = nil
        end
        super
      end

      def authenticatable_salt
        self.password_salt
      end

      # Verifies whether an incoming_password (ie from sign in) is the user password.
      def valid_password?(incoming_password)
        password_digest(incoming_password) == self.encrypted_password
      end

    protected

      # Digests the password using the configured encryptor.
      def password_digest(password)
        if self.password_salt.present?
          self.class.encryptor_class.digest(password, self.class.stretches, self.password_salt, self.class.pepper)
        elsif password.blank? && self.class.password_allow_blank
          ""
        end
      end

      module ClassMethods
        Devise::Models.config(self, :encryptor, :password_allow_blank)

        # Returns the class for the configured encryptor.
        def encryptor_class
          @encryptor_class ||= case encryptor
            when :bcrypt
              raise "In order to use bcrypt as encryptor, simply remove :encryptable from your devise model"
            when nil
              raise "You need to give an :encryptor as option in order to use :encryptable"
            else
              ::Devise::Encryptors.const_get(encryptor.to_s.classify)
          end
        end

        def password_salt
          self.encryptor_class.salt(self.stretches)
        end
      end
    end
  end
end
