module Devise
  module Models
    module Oauthable
      extend ActiveSupport::Concern

      module ClassMethods
        Devise::Models.config(self, :oauth_providers)
      end
    end
  end
end