module Devise
  module Encryptors
    # Encryptor for BCrypt. It ignores the values given for salt,
    # as it is repsonsible for managing its own salt.
    class BCrypt < Base
      def self.digest(password, stretches, _salt, pepper)
        ::BCrypt::Password.create("#{password}#{pepper}", :cost => stretches).to_s
      end

      def self.compare(encrypted_password, password, _stretches, _salt, pepper)
        bcrypt   = ::BCrypt::Password.new(encrypted_password)
        password = ::BCrypt::Engine.hash_secret("#{password}#{pepper}", bcrypt.salt)
        Devise.secure_compare(password, encrypted_password)
      end
    end
  end
end
