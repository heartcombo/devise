begin
  require "scrypt"
rescue LoadError
  $stderr.puts "You must install the scrypt gem in order to use SCrypt encryption."
  exit(1)
end

module Devise
  module Encryptors
    class SCrypt < Base
      def self.digest(password, stretches, salt, pepper)
        ::SCrypt::Engine.hash_secret("#{password}#{pepper}", salt)
      end

      def self.compare(encrypted_password, password, stretches, salt, pepper)
        salt = ::SCrypt::Password.new(encrypted_password).salt
        Devise.secure_compare(encrypted_password, digest(password, stretches, salt, pepper))
      end
    end
  end
end
