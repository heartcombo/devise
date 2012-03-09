module Devise
  module Encryptors
    class BCrypt < Base
      def self.digest(password, salt, stretches, pepper)
        ::BCrypt::Engine.hash_secret("#{password}#{pepper}",salt, stretches)
      end

      def compare(encrypted_password, password, salt, stretches, pepper)
        salt = ::BCrypt::Password.new(encrypted_password).salt
        Devise.secure_compare(encrypted_password, digest(password, salt, stretches, pepper))
      end
    end
  end
end
