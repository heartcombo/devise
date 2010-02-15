require 'devise/strategies/http_authenticatable'

module Devise
  module Models
    # Adds HttpAuthenticatable behavior to your model. It expects that your
    # model class responds to authenticate and authentication_keys methods
    # (which for example are defined in authenticatable).
    module HttpAuthenticatable
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        # Authenticate an user using http.
        def authenticate_with_http(username, password)
          authenticate(authentication_keys.first => username, :password => password)
        end
      end
    end
  end
end
