# frozen_string_literal: true

require 'bcrypt'
require 'digest'

module Devise
  module Encryptor
    def self.digest(klass, password)
      if klass.pepper.present?
        password = "#{password}#{klass.pepper}"
      end
      # This converts the password (of any length) into a fixed
      # 64-character hex string, safely under the 72-char limit
      password = Digest::SHA256.hexdigest(password)

      # BCrypt the pre-hashed string
      ::BCrypt::Password.create(password, cost: klass.stretches).to_s
    end

    # Compares a potential password with a stored hash.
    #
    # It attempts the new (SHA-256 -> BCrypt) method first.
    # If that fails, it falls back to the old (direct BCrypt) method
    # to support existing passwords that were not pre-hashed
    def self.compare(klass, hashed_password, password)
      return false if hashed_password.blank?

      begin
        bcrypt = ::BCrypt::Password.new(hashed_password)
      rescue ::BCrypt::Errors::InvalidHash
        return false
      end

      if klass.pepper.present?
        password = "#{password}#{klass.pepper}"
      end

      # This is for passwords created with the new `digest` method.
      pre_hashed_password = Digest::SHA256.hexdigest(password)
      new_style_hash = ::BCrypt::Engine.hash_secret(pre_hashed_password, bcrypt.salt)

      return true if Devise.secure_compare(new_style_hash, hashed_password)

      # This is for passwords created before this change
      # We re-run the original logic
      old_style_hash = ::BCrypt::Engine.hash_secret(password, bcrypt.salt)
      Devise.secure_compare(old_style_hash, hashed_password)
    end
  end
end
