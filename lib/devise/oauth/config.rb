require 'active_support/core_ext/array/wrap'

module Devise
  module Oauth
    class Config
      attr_reader :name, :scope, :client

      def initialize(name, app_id, app_secret, options)
        @name   = name
        @scope  = Array.wrap(options.delete(:scope))
        @client = OAuth2::Client.new(app_id, app_secret, options)
      end

      def authorize_url(options)
        options[:scope] ||= @scope.join(',')
        client.web_server.authorize_url(options)
      end

      def access_token_by_code(code, redirect_uri=nil)
        client.web_server.get_access_token(code, :redirect_uri => redirect_uri)
      end

      def access_token_by_token(token)
        OAuth2::AccessToken.new(client, token)
      end
    end
  end
end