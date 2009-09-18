module Devise
  module PerishableToken

    def self.included(base)
      base.class_eval do
#        extend ClassMethods

        before_create :reset_perishable_token
      end
    end

    # Generates a new random token for confirmation, based on actual Time and salt
    #
    def reset_perishable_token
      self.perishable_token = secure_digest(Time.now.utc, random_string, password)
    end

    # Resets the perishable token with and save the record without validating
    #
    def reset_perishable_token!
      reset_perishable_token and save(false)
    end
  end
end

