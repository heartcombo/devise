require 'devise/strategies/authenticatable'
require 'devise/serializers/authenticatable'

module Devise
  module Models
    module SessionSerializer
      # Hook to serialize user into session. Overwrite if you want.
      def serialize_into_session(record)
        [record.class, record.id]
      end

      # Hook to serialize user from session. Overwrite if you want.
      def serialize_from_session(keys)
        klass, id = keys
        raise "#{self} cannot serialize from #{klass} session since it's not its ancestors" unless klass <= self
        klass.find(:first, :conditions => { :id => id })
      end
    end

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

          attr_reader :password
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

      # Update record attributes when :old_password matches, otherwise returns
      # error on :old_password.
      def update_with_password(params={})
        if valid_password?(params[:old_password])
          update_attributes(params)
        else
          errors.add(:old_password, :invalid)
          false
        end
      end

      # Overwrite update_attributes to not care for blank passwords.
      def update_attributes(attributes)
        [:password, :password_confirmation].each do |k|
          attributes.delete(k) unless attributes[k].present?
        end
        super
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
          valid_for_authentication(resource, attributes) if resource
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

        # Contains the logic used in authentication. Overwritten by other devise modules.
        def valid_for_authentication(resource, attributes)
          resource if resource.valid_password?(attributes[:password])
        end

        Devise::Models.config(self, :pepper, :stretches, :encryptor, :authentication_keys)
      end
    end
  end
end
