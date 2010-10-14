require 'devise/omniauth'

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
    module Omniauthable
      extend ActiveSupport::Concern

      module ClassMethods
        Devise::Models.config(self, :omniauth_providers)
      end
    end
  end
end