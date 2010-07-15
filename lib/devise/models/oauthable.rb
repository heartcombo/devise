module Devise
  module Models
    # Adds OAuth support to your model. The whole workflow is deeply discussed in the
    # README. This module adds just a class +oauth_access_token+ helper to your model
    # which assists you on creating an access token. All the other OAuth hooks in
    # Devise must be implemented by yourself in your application.
    #
    # == Options
    #
    # Oauthable adds the following options to devise_for:
    #
    #   * +oauth_providers+: Which providers are avaialble to this model. It expects an array:
    #
    #       devise_for :database_authenticatable, :oauthable, :oauth_providers => [:twitter]
    #
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