module Devise
  module ActionController

    def self.included(base)
      base.class_eval do
        include Devise::Controllers::Authenticable
        include Devise::Controllers::Resources
        include Devise::Controllers::UrlHelpers
        include Devise::Controllers::Filters
      end
    end
  end
end
