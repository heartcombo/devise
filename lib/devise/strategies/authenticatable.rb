require 'devise/strategies/base'

module Devise
  module Strategies
    # This strategy should be used as basis for authentication strategies. It retrieves
    # parameters both from params or from http authorization headers. See database_authenticatable
    # for an example.
    class Authenticatable < Base
      attr_accessor :authentication_hash, :password

      def valid?
        valid_for_http_auth? || valid_for_params_auth?
      end

    private

      # Simply invokes valid_for_authentication? with the given block and deal with the result.
      def validate(resource, &block)
        result = resource && resource.valid_for_authentication?(&block)

        case result
        when Symbol, String
          fail!(result)
        else
          result
        end 
      end

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