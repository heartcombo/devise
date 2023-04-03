# frozen_string_literal: true

require 'bcrypt'

module Devise
  module Encryptors
    module BCryptEncryptor
      def self.digest(klass, password)
        if klass.pepper.present?
          password = "#{password}#{klass.pepper}"
        end
        ::BCrypt::Password.create(password, cost: klass.stretches).to_s
      end

      def self.compare(klass, hashed_password, password)
        return false if hashed_password.blank?
        bcrypt   = ::BCrypt::Password.new(hashed_password)
        password = ::BCrypt::Engine.hash_secret("#{password}#{klass.pepper}", bcrypt.salt)
        Devise.secure_compare(password, hashed_password)
      end
    end
  end
end
