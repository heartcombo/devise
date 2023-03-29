# frozen_string_literal: true


module Devise
  module Encryptor

    class EncryptorNotFound < NameError
      def initialize(encryptor)
        @encryptor = encryptor
        super("Could not find an encryptor with name `#{encryptor}'. " \
              "Please ensure :encryptor option is set with one of the predefined values #{Devise::ENCRYPTORS.keys.inspect} or not at all to use the default(bcrypt) encryptor.")
      end
    end

    def self.digest(klass, password)
      Devise.encryptor.digest(klass, password)
    end

    def self.compare(klass, hashed_password, password)
      Devise.encryptor.compare(klass, password)
    end

  end
end
