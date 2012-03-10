require 'devise/strategies/database_authenticatable'

module Devise
  module Models
    # Encryptable module adds support to several encryptors wrapping
    # them in a salt and pepper mechanism to increase security.
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

      def self.required_fields(klass)
        [:password_salt]
      end

      # Generates password salt when setting the password.
      def password=(new_password)
        self.password_salt = self.class.password_salt if new_password.present?
        super
      end

      # Overrides authenticatable salt to use the new password_salt
      # column. authenticatable_salt is used by `valid_password?`
      # and by other modules whenever there is a need for a random
      # token based on the user password.
      def authenticatable_salt
        self.password_salt
      end

    protected

      # Digests the password using the configured encryptor.
      def password_digest(password)
        if password_salt.present?
          encryptor_class.digest(password, self.class.stretches, authenticatable_salt, self.class.pepper)
        end
      end

      def encryptor_class
        self.class.encryptor_class
      end

      module ClassMethods
        Devise::Models.config(self, :encryptor)

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
