require 'devise/strategies/base'

module Devise
  module Strategies
    # Sign in an user using HTTP authentication.
    class HttpAuthenticatable < Base
      def valid?
        http_authentication? && mapping.to.respond_to?(:authenticate_with_http)
      end

      def authenticate!
        username, password = username_and_password

        if resource = mapping.to.authenticate_with_http(username, password)
          success!(resource)
        else
          custom!([401, custom_headers, ["HTTP Basic: Access denied.\n"]])
        end
      end

    private

      def username_and_password
        decode_credentials(request).split(/:/, 2)
      end

      def http_authentication
        request.env['HTTP_AUTHORIZATION']   ||
        request.env['X-HTTP_AUTHORIZATION'] ||
        request.env['X_HTTP_AUTHORIZATION'] ||
        request.env['REDIRECT_X_HTTP_AUTHORIZATION']
      end
      alias :http_authentication? :http_authentication

      def decode_credentials(request)
        ActiveSupport::Base64.decode64(http_authentication.split(' ', 2).last || '')
      end

      def custom_headers
        {
          "Content-Type" => Mime::Type.lookup_by_extension(request.template_format.to_s).to_s,
          "WWW-Authenticate" => %(Basic realm="#{Devise.http_authentication_realm.gsub(/"/, "")}")
        }
      end
    end
  end
end

Warden::Strategies.add(:http_authenticatable, Devise::Strategies::HttpAuthenticatable)
