require 'devise/strategies/authenticatable'
require 'devise/strategies/http_authenticatable'

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

          attr_reader :password, :current_password
          attr_accessor :password_confirmation
        end
      end

      # TODO Remove me in next release
      def old_password
        ActiveSupport::Deprecation.warn "old_password is deprecated, please use current_password instead", caller
        @old_password
      end

      # Regenerates password salt and encrypted password each time password is set,
      # and then trigger any "after_changed_password"-callbacks.
      def password=(new_password)
        @password = new_password

        if @password.present?
          self.password_salt = self.class.encryptor_class.salt
          self.encrypted_password = password_digest(@password)
        end
      end

      # Verifies whether an incoming_password (ie from sign in) is the user password.
      def valid_password?(incoming_password)
        password_digest(incoming_password) == self.encrypted_password
      end

      # Verifies whether an +incoming_authentication_token+ (i.e. from single access URL)
      # is the user authentication token.
      def valid_authentication_token?(incoming_auth_token)
        incoming_auth_token == self.authentication_token
      end

      # Checks if a resource is valid upon authentication.
      def valid_for_authentication?(attributes)
        valid_password?(attributes[:password])
      end

      # Set password and password confirmation to nil
      def clean_up_passwords
        self.password = self.password_confirmation = nil
      end

      # Update record attributes when :current_password matches, otherwise returns
      # error on :current_password. It also automatically rejects :password and
      # :password_confirmation if they are blank.
      def update_with_password(params={})
        # TODO Remove me in next release
        if params[:old_password].present?
          params[:current_password] ||= params[:old_password]
          ActiveSupport::Deprecation.warn "old_password is deprecated, please use current_password instead", caller
        end

        params.delete(:password) if params[:password].blank?
        params.delete(:password_confirmation) if params[:password_confirmation].blank?

        result = if valid_password?(params[:current_password])
          update_attributes(params)
        else
          message = params[:current_password].blank? ? :blank : :invalid
          self.class.add_error_on(self, :current_password, message, false)
          self.attributes = params
          false
        end

        clean_up_passwords unless result
        result
      end

      protected

        # Digests the password using the configured encryptor.
        def password_digest(password)
          self.class.encryptor_class.digest(password, self.class.stretches, self.password_salt, self.class.pepper)
        end

      module ClassMethods
        Devise::Models.config(self, :pepper, :stretches, :encryptor, :authentication_keys)

        # Authenticate a user based on configured attribute keys. Returns the
        # authenticated user if it's valid or nil.
        def authenticate(attributes={})
          return unless authentication_keys.all? { |k| attributes[k].present? }
          conditions = attributes.slice(*authentication_keys)
          resource = find_for_authentication(conditions)
          resource if resource.try(:valid_for_authentication?, attributes)
        end

        # Authenticate an user using http.
        def authenticate_with_http(username, password)
          authenticate(authentication_keys.first => username, :password => password)
        end

        # Returns the class for the configured encryptor.
        def encryptor_class
          @encryptor_class ||= ::Devise::Encryptors.const_get(encryptor.to_s.classify)
        end

      protected

        # Find first record based on conditions given (ie by the sign in form).
        # Overwrite to add customized conditions, create a join, or maybe use a
        # namedscope to filter records while authenticating.
        # Example:
        #
        #   def self.find_for_authentication(conditions={})
        #     conditions[:active] = true
        #     find(:first, :conditions => conditions)
        #   end
        #
        def find_for_authentication(conditions)
          find(:first, :conditions => conditions)
        end
      end
    end
  end
end
