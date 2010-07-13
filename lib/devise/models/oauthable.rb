module Devise
  module Models
    module Oauthable
      extend ActiveSupport::Concern

      module ClassMethods
        def oauth_configs
          Devise.oauth_configs.slice(*oauth_providers)
        end

        Devise::Models.config(self, :oauth_providers)
      end
    end
  end
end