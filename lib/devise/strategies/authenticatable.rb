require 'devise/strategies/base'

module Devise
  module Strategies
    class Authenticatable < Base
      attr_accessor :authentication_hash, :password

      def valid?
        valid_for_http_auth? || valid_for_params_auth?
      end

    private

      def valid_for_http_auth?
        mapping.to.http_authenticatable? && request.authorization && set_http_auth_hash
      end

      def valid_for_params_auth?
        valid_controller? && valid_params? && set_params_auth_hash
      end

      def valid_controller?
        mapping.controllers[:sessions] == params[:controller]
      end

      def valid_params?
        params[scope].is_a?(Hash)
      end

      def set_http_auth_hash
        keys = [authentication_keys.first, :password]
        with_authentication_hash Hash[*keys.zip(decode_credentials).flatten]
      end

      def decode_credentials
        username_and_password = request.authorization.split(' ', 2).last || ''
        ActiveSupport::Base64.decode64(username_and_password).split(/:/, 2)
      end

      def set_params_auth_hash
        with_authentication_hash params[scope]
      end

      def with_authentication_hash(hash)
        self.authentication_hash = hash.slice(*authentication_keys)
        self.password = hash[:password]
        authentication_keys.all?{ |k| authentication_hash[k].present? } && password.present?
      end

      def authentication_keys
        @authentication_keys ||= mapping.to.authentication_keys
      end
    end
  end
end