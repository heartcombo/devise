module Devise
  module PerishableToken

    def self.included(base)
      base.class_eval do
#        extend ClassMethods

        before_create :generate_perishable_token
      end
    end

    private

      # Generates a new random token for confirmation, based on actual Time and salt
      #
      def generate_perishable_token
        self.perishable_token = secure_digest(Time.now.utc, random_string, password)
      end
  end
end

