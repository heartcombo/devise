module Devise
  module ActionView

    def self.included(base)
      base.class_eval do
        include Devise::Controllers::Resources
        include Devise::Controllers::UrlHelpers
      end
    end
  end
end
