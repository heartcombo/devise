require 'devise/hooks/timeoutable'

module Devise
  module Models

    # Timeoutable
    module Timeoutable

      def self.included(base)
        base.extend ClassMethods
      end

      # Checks whether the user session has expired based on configured time.
      def timeout?(last_access)
        last_access && last_access <= self.class.timeout.ago.utc
      end

      module ClassMethods
        Devise::Models.config(self, :timeout)
      end
    end
  end
end
