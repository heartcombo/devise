require "bcrypt"

module Devise
  # Implements a way of adding different encryptions.
  # The class should implement a self.digest method that taks the following params:
  #   - password
  #   - stretches: the number of times the encryption will be applied
  #   - salt: the password salt as defined by devise
  #   - pepper: Devise config option
  #
  module Encryptors
    # = BCrypt 
    # Uses the BCrypt hash algorithm to encrypt passwords.
    class BCrypt
      
      # Gererates a default password digest based on stretches, salt, pepper and the
      # incoming password. We don't strech it ourselves since BCrypt does so internally.
      def self.digest(password, stretches, salt, pepper)
        ::BCrypt::Engine.hash_secret(password, [salt, pepper].flatten.join('xx'), stretches)
      end

    end
  end
end
