module Devise
  module Oauth
    class Config
      attr_reader :scope, :client

      def initialize(app_id, app_secret, options)
        @scope  = Array.wrap(options.delete(:scope)).join(",")
        @client = OAuth2::Client.new(app_id, app_secret, options)
      end
    end
  end
end