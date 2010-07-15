module Devise
  module Models
    module Oauthable
      extend ActiveSupport::Concern

      module ClassMethods
        def oauth_configs #:nodoc:
          Devise.oauth_configs.slice(*oauth_providers)
        end

        # Pass a token stored in the database to this object to get an OAuth2::AccessToken
        # object back, as the one received in your model hook.
        #
        # For each provider you add, you may want to add a hook to retrieve the token based
        # on the column you stored the token in the database. For example, you may want to
        # the following for twitter:
        #
        #   def oauth_twitter_token
        #     @oauth_twitter_token ||= self.class.oauth_access_token(:twitter, twitter_token)
        #   end
        #
        # You can call get, post, put and delete in this object to access Twitter's API.
        def oauth_access_token(provider, token)
          oauth_configs[provider].access_token_by_token(token)
        end

        # TODO Implement this method in the future.
        # def refresh_oauth_token(provider, refresh_token)
        #   returns access_token
        # end

        Devise::Models.config(self, :oauth_providers)
      end
    end
  end
end