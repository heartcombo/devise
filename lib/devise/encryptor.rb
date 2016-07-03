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
      if hashed_password.present?
        # Handle the case where password is encrypted using bcrypt
        bcrypt = ::BCrypt::Password.new(hashed_password)
        if klass.pepper.present?
          password = "#{password}#{klass.pepper}"
        end
        bcrypt_hashed_password = ::BCrypt::Engine.hash_secret(password, bcrypt.salt)

        # First use bcrypt to check password
        return Devise.secure_compare(bcrypt_hashed_password, hashed_password)
      elsif salt.present? && node_hashed_password.present?
        # If comparison using bcrypt fails, try to check the password
        # using sha1.
        #
        # If the user doesn't have a salt, then fail authentication.
        #
        key = salt
        data = password
        digest = OpenSSL::Digest.new('sha1')
        instance = OpenSSL::HMAC.new(key, digest)
        sha_hashed_password = instance.update(data).to_s
        return Devise.secure_compare(node_hashed_password, sha_hashed_password)
      end

      false
    end
  end
end
