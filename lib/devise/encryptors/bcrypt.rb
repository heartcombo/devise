module Devise
  module Encryptors
    class BCrypt < Base
      def self.digest(password, stretches, salt, pepper)
        ::BCrypt::Engine.hash_secret("#{password}#{pepper}",salt, stretches)
      end

      def self.compare(encrypted_password, password, stretches, salt, pepper)
        salt = ::BCrypt::Password.new(encrypted_password).salt
        Devise.secure_compare(encrypted_password, digest(password, stretches, salt, pepper))
      end
    end
  end
end
