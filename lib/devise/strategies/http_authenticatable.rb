require 'devise/strategies/base'

module Devise
  module Strategies
    # Sign in an user using HTTP authentication.
    class HttpAuthenticatable < Base
      def valid?
        request.authorization
      end

      def authenticate!
        username, password = username_and_password

        if resource = mapping.to.authenticate_with_http(username, password)
          success!(resource)
        else
          fail!(:invalid)
        end
      end

    private

      def username_and_password
        decode_credentials(request).split(/:/, 2)
      end

      def decode_credentials(request)
        ActiveSupport::Base64.decode64(request.authorization.split(' ', 2).last || '')
      end
    end
  end
end

Warden::Strategies.add(:http_authenticatable, Devise::Strategies::HttpAuthenticatable)
