require 'digest/sha1'

module Devise
  module Models
    
    # Implements a way of adding different encryptions.
    # The class should implement a self.digest method that taks the following params:
    #   - password to be digest
    #   - params (#hash)
    #     - salt: the password salt as defined by devise
    #     - pepper: Devise config option
    #     - stretches: Devise config option
    #
    module Encryptors
      # = Sha1
      #
      # Uses the Sha1 hash algorithm to encrypt passwords.
      class Sha1
        
        # Gererates a default password digest based on salt, pepper and the
        # incoming password.
        def self.digest(password_to_digest, params)
          digest = params[:pepper]
          Devise.stretches.times { digest = self.secure_digest(params[:salt], digest, password_to_digest, params[:pepper]) }
          digest
        end

        private

          # Generate a SHA1 digest joining args. Generated token is something like
          # 
          #   --arg1--arg2--arg3--argN--
          def self.secure_digest(*tokens)
            ::Digest::SHA1.hexdigest('--' << tokens.flatten.join('--') << '--')
          end        
        
      end
    end
  end
end