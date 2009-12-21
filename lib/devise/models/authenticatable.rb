require 'devise/strategies/authenticatable'
require 'devise/models/session_serializer'

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
          extend SessionSerializer

          attr_reader :password, :old_password
          attr_accessor :password_confirmation
        end
      end

      # Regenerates password salt and encrypted password each time password is set.
      def password=(new_password)
        @password = new_password

        if @password.present?
          self.password_salt = Devise.friendly_token
          self.encrypted_password = password_digest(@password)
        end
      end

      # Verifies whether an incoming_password (ie from sign in) is the user password.
      def valid_password?(incoming_password)
        password_digest(incoming_password) == encrypted_password
      end

      # Checks if a resource is valid upon authentication.
      def valid_for_authentication?(attributes)
        valid_password?(attributes[:password])
      end

      # Update record attributes when :old_password matches, otherwise returns
      # error on :old_password.
      def update_with_password(params={})
        if valid_password?(params[:old_password])
          update_attributes(params)
        else
          self.class.add_error_on(self, :old_password, :invalid, false)
          false
        end
      end

      protected

        # Digests the password using the configured encryptor.
        def password_digest(password)
          self.class.encryptor_class.digest(password, self.class.stretches, password_salt, self.class.pepper)
        end

      module ClassMethods
        # Authenticate a user based on configured attribute keys. Returns the
        # authenticated user if it's valid or nil. Attributes are by default
        # :email and :password, but the latter is always required.
        def authenticate(attributes={})
          return unless authentication_keys.all? { |k| attributes[k].present? }
          conditions = attributes.slice(*authentication_keys)
          resource = find_for_authentication(conditions)
          if respond_to?(:valid_for_authentication)
            ActiveSupport::Deprecation.warn "valid_for_authentication class method is deprecated. " <<
              "Use valid_for_authentication? in the instance instead."
            valid_for_authentication(resource, attributes)
          elsif resource.try(:valid_for_authentication?, attributes)
            resource
          end
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

        Devise::Models.config(self, :pepper, :stretches, :encryptor, :authentication_keys)
      end
    end
  end
end
