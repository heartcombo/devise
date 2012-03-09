module Devise
  module Encryptors
    class BCrypt < Base
      def self.digest(password, salt, stretches, pepper)
        ::BCrypt::Engine.hash_secret("#{password}#{pepper}",salt, stretches)
      end
    end
  end
end
