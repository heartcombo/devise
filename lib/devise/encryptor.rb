require 'bcrypt'

module Devise
  module Encryptor
    def self.digest(klass, password)
      if klass.pepper.present?
        password = "#{password}#{klass.pepper}"
      end
      ::BCrypt::Password.create(password, cost: klass.stretches).to_s
    end

    def self.compare(klass, salt, node_hashed_password, hashed_password, password)
      return false if hashed_password.blank?
      # Handle the case where password is encrypted using bcrypt
      bcrypt   = ::BCrypt::Password.new(hashed_password)
      if klass.pepper.present?
        password = "#{password}#{klass.pepper}"
      end
      bcrypt_hashed_password = ::BCrypt::Engine.hash_secret(password, bcrypt.salt)

      # First use bcrypt to check password
      if Devise.secure_compare(bcrypt_hashed_password, hashed_password) == true
        return true
      end

      # If comparison using bcrypt fails, try to check the password
      # using sha1. 
      # 
      # If the user doesn't have a salt, then fail authentication. 
      # 
      if salt.blank? || node_hashed_password.blank?
        return false
      elsif salt.present?
        key = salt
        data = password
        digest = OpenSSL::Digest.new('sha1')
        instance = OpenSSL::HMAC.new(key, digest)
        sha_hashed_password = instance.update(data).to_s
        Devise::Encryptor.compare_sha_password(node_hashed_password, sha_hashed_password)
      end
    end

    def self.compare_sha_password(node_hashed_password, sha_hashed_password)
      if Devise.secure_compare(node_hashed_password, sha_hashed_password) == true
        self.password = password
        self.node_hashed_password = nil
        self.salt = nil
        return true
      else
        return false
      end
    end
  end
end
