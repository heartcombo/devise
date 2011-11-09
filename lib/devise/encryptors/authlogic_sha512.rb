require "digest/sha2"

module Devise
  module Encryptors
    # = AuthlogicSha512
    # Simulates Authlogic's default encryption mechanism.
    # Warning: it uses Devise's stretches configuration to port Authlogic's one. Should be set to 20 in the initializer to simulate
    #  the default behavior.
    class AuthlogicSha512 < Base
      # Generates a default password digest based on salt, pepper and the
      # incoming password.
      def self.digest(password, stretches, salt, pepper)
        digest = [password, salt].flatten.join('')
        stretches.times { digest = Digest::SHA512.hexdigest(digest) }
        digest
      end
    end
  end
end