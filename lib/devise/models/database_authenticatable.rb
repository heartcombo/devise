require 'devise/strategies/database_authenticatable'

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
    # Examples:
    #
    #    User.find(1).valid_password?('password123')         # returns true/false
    #
    module DatabaseAuthenticatable
      extend ActiveSupport::Concern

      included do
        attr_reader :password, :current_password
        attr_accessor :password_confirmation
      end

      # Regenerates password salt and encrypted password each time password is set,
      # and then trigger any "after_changed_password"-callbacks.
      def password=(new_password)
        @password = new_password

        if @password.present?
          self.password_salt = self.class.password_salt
          self.encrypted_password = password_digest(@password)
        end
      end

      # Verifies whether an incoming_password (ie from sign in) is the user password.
      def valid_password?(incoming_password)
        Devise.secure_compare(password_digest(incoming_password), self.encrypted_password)
      end

      # Set password and password confirmation to nil
      def clean_up_passwords
        self.password = self.password_confirmation = nil
      end

      # Update record attributes when :current_password matches, otherwise returns
      # error on :current_password. It also automatically rejects :password and
      # :password_confirmation if they are blank.
      def update_with_password(params={})
        current_password = params.delete(:current_password)

        if params[:password].blank?
          params.delete(:password)
          params.delete(:password_confirmation) if params[:password_confirmation].blank?
        end

        result = if valid_password?(current_password)
          update_attributes(params)
        else
          self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
          self.attributes = params
          false
        end

        clean_up_passwords
        result
      end

      def after_database_authentication
      end

    protected

      # Digests the password using the configured encryptor.
      def password_digest(password)
        if self.password_salt.present?
          self.class.encryptor_class.digest(password, self.class.stretches, self.password_salt, self.class.pepper)
        end
      end

      module ClassMethods
        Devise::Models.config(self, :pepper, :stretches, :encryptor)

        # Returns the class for the configured encryptor.
        def encryptor_class
          @encryptor_class ||= ::Devise::Encryptors.const_get(encryptor.to_s.classify)
        end

        def password_salt
          self.encryptor_class.salt(self.stretches)
        end

        # We assume this method already gets the sanitized values from the
        # DatabaseAuthenticatable strategy. If you are using this method on
        # your own, be sure to sanitize the conditions hash to only include
        # the proper fields.
        def find_for_database_authentication(conditions)
          find_for_authentication(conditions)
        end
      end
    end
  end
end
