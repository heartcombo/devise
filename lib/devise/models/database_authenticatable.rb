require 'devise/strategies/database_authenticatable'
require 'bcrypt'

module Devise
  module Models
    # Authenticatable Module, responsible for encrypting password and validating
    # authenticity of a user while signing in.
    #
    # == Options
    #
    # DatabaseAuthenticable adds the following options to devise_for:
    #
    #   * +pepper+: a random string used to provide a more secure hash. Use
    #     `rake secret` to generate new keys.
    #
    #   * +stretches+: the cost given to bcrypt.
    #
    # == Examples
    #
    #    User.find(1).valid_password?('password123')         # returns true/false
    #
    module DatabaseAuthenticatable
      extend ActiveSupport::Concern

      included do
        attr_reader :password, :current_password
        attr_accessor :password_confirmation
      end

      def self.required_fields(klass)
        [:encrypted_password] + klass.authentication_keys
      end

      # Generates password encryption based on the given value.
      def password=(new_password)
        @password = new_password
        self.encrypted_password = password_digest(@password) if @password.present?
      end

      # Verifies whether an password (ie from sign in) is the user password.
      def valid_password?(password)
        logger.debug("Determining if the password is valid...")
        return false if encrypted_password.blank?
        logger.debug("The password is not blank so we are encrypting it and comparing the result...")
        bcrypt   = ::BCrypt::Password.new(encrypted_password)
        password = ::BCrypt::Engine.hash_secret("#{password}#{self.class.pepper}", bcrypt.salt)
        identical = Devise.secure_compare(password, encrypted_password)

        if identical
          logger.debug("The encrypted password matches the encrypted password on record.")
        else
          logger.debug("The encrypted password does not match the encrypted password on record.")
        end

        identical
      end

      # Set password and password confirmation to nil
      def clean_up_passwords
        self.password = self.password_confirmation = nil
      end

      # Update record attributes when :current_password matches, otherwise returns
      # error on :current_password. It also automatically rejects :password and
      # :password_confirmation if they are blank.
      def update_with_password(params, *options)
        current_password = params.delete(:current_password)

        if params[:password].blank?
          params.delete(:password)
          params.delete(:password_confirmation) if params[:password_confirmation].blank?
        end

        result = if valid_password?(current_password)
          update_attributes(params, *options)
        else
          self.attributes = params
          self.valid?
          self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
          false
        end

        clean_up_passwords
        result
      end

      # Updates record attributes without asking for the current password.
      # Never allows to change the current password. If you are using this
      # method, you should probably override this method to protect other
      # attributes you would not like to be updated without a password.
      #
      # Example:
      #
      #   def update_without_password(params={})
      #     params.delete(:email)
      #     super(params)
      #   end
      #
      def update_without_password(params, *options)
        params.delete(:password)
        params.delete(:password_confirmation)

        result = update_attributes(params, *options)
        clean_up_passwords
        result
      end

      def after_database_authentication
      end

      # A reliable way to expose the salt regardless of the implementation.
      def authenticatable_salt
        encrypted_password[0,29] if encrypted_password
      end

    protected

      # Digests the password using bcrypt.
      def password_digest(password)
        ::BCrypt::Password.create("#{password}#{self.class.pepper}", :cost => self.class.stretches).to_s
      end

      module ClassMethods
        Devise::Models.config(self, :pepper, :stretches)

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
