require "bcrypt"

module Devise
  module Encryptors
    # = BCrypt
    # Uses the BCrypt hash algorithm to encrypt passwords.
    class Bcrypt < Base

      # Gererates a default password digest based on stretches, salt, pepper and the
      # incoming password. We don't strech it ourselves since BCrypt does so internally.
      def self.digest(password, stretches, salt, pepper)
        ::BCrypt::Engine.hash_secret([password, pepper].join, salt, stretches)
      end

      def self.salt
        ::BCrypt::Engine.generate_salt
      end

    end
  end
end
