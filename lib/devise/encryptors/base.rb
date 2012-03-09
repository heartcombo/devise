module Devise
  # Implements a way of adding different encryptions.
  # The class should implement a self.digest method that taks the following params:
  #   - password
  #   - stretches: the number of times the encryption will be applied
  #   - salt: the password salt as defined by devise
  #   - pepper: Devise config option
  #
  module Encryptors
    class Base
      def self.digest
        raise NotImplemented
      end

      def self.salt(stretches)
        Devise.friendly_token[0,20]
      end

      def self.compare(encrypted_password, password, stretches, salt, pepper)
        Devise.secure_compare(encrypted_password, digest(password, stretches, salt, pepper))
      end
    end
  end
end
