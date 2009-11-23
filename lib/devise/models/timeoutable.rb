require 'devise/hooks/timeoutable'

module Devise
  module Models

    # Timeoutable
    module Timeoutable

      def self.included(base)
        base.class_eval do
          extend ClassMethods
        end
      end

      module ClassMethods
      end

      Devise::Models.config(self, :timeout)
    end
  end
end
