require "digest/sha1"

module Devise
  module Encryptors
    # = ClearanceSha1
    # Simulates Clearance's default encryption mechanism.
    # Warning: it uses Devise's pepper to port the concept of REST_AUTH_SITE_KEY
    # Warning: it uses Devise's stretches configuration to port the concept of REST_AUTH_DIGEST_STRETCHES
    class ClearanceSha1 < Base
      # Gererates a default password digest based on salt, pepper and the
      # incoming password.
      def self.digest(password, stretches, salt, pepper)
        Digest::SHA1.hexdigest("--#{salt}--#{password}--")
      end
    end
  end
end