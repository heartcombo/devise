module Devise
  module Models
    # Allows an account to be disabled by setting a "disabled?" flag
    # to true.
    module Disableable
      extend  ActiveSupport::Concern

      # Overwrites active_for_authentication? from
      # Devise::Models::Activatable for locking purposes by verifying
      # whether a user is active to sign in or not based on disabled?
      def active_for_authentication?
        super && !disabled?
      end

      # Overwrites invalid_message from
      # Devise::Models::Authenticatable to define the correct reason
      # for blocking the sign in.
      def inactive_message
        disabled? ? :disabled : super
      end
    end
  end
end
