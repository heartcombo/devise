require 'devise/hooks/timeoutable'

module Devise
  module Models
    # Timeoutable takes care of veryfing whether a user session has already
    # expired or not. When a session expires after the configured time, the user
    # will be asked for credentials again, it means, he/she will be redirected
    # to the sign in page.
    #
    # Configuration:
    #
    #   timeout: the time you want to timeout the user session without activity.
    module Timeoutable
      def self.included(base)
        base.extend ClassMethods
      end

      # Checks whether the user session has expired based on configured time.
      def timedout?(last_access)
        last_access && last_access <= self.class.timeout_in.ago
      end

      module ClassMethods
        Devise::Models.config(self, :timeout_in)
      end
    end
  end
end
