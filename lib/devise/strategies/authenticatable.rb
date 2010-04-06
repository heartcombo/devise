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

      # Check if this is strategy is valid for http authentication.
      def valid_for_http_auth?
        http_authenticatable? && request.authorization && with_authentication_hash(http_auth_hash)
      end

      # Check if this is strategy is valid for params authentication.
      def valid_for_params_auth?
        params_authenticatable? && valid_request? &&
          valid_params? && with_authentication_hash(params_auth_hash)
      end

      # Check if the model accepts this strategy as http authenticatable.
      def http_authenticatable?
        mapping.to.http_authenticatable?(authenticatable_name)
      end

      # Check if the model accepts this strategy as params authenticatable.
      def params_authenticatable?
        mapping.to.params_authenticatable?(authenticatable_name)
      end

      # Extract the appropriate subhash for authentication from params.
      def params_auth_hash
         params[scope]
       end

      # Extract a hash with attributes:values from the http params.
      def http_auth_hash
        keys = [authentication_keys.first, :password]
        Hash[*keys.zip(decode_credentials).flatten]
      end

      # By default, a request is valid  if the controller is allowed and the VERB is POST.
      def valid_request?
        valid_controller? && valid_verb?
      end

      # Check if the controller is valid for params authentication.
      def valid_controller?
        mapping.controllers[:sessions] == params[:controller]
      end

      # Check if the params_auth_hash is valid for params authentication.
      def valid_verb?
        request.post?
      end

      # If the request is valid, finally check if params_auth_hash returns a hash.
      def valid_params?
        params_auth_hash.is_a?(Hash)
      end

      # Helper to decode credentials from HTTP.
      def decode_credentials
        username_and_password = request.authorization.split(' ', 2).last || ''
        ActiveSupport::Base64.decode64(username_and_password).split(/:/, 2)
      end

      # Sets the authentication hash and the password from params_auth_hash or http_auth_hash.
      def with_authentication_hash(hash)
        self.authentication_hash = hash.slice(*authentication_keys)
        self.password = hash[:password]
        authentication_keys.all?{ |k| authentication_hash[k].present? }
      end

      # Holds the authentication keys.
      def authentication_keys
        @authentication_keys ||= mapping.to.authentication_keys
      end

      # Holds the authenticatable name for this class. Devise::Strategies::DatabaseAuthenticatable
      # becomes simply :database.
      def authenticatable_name
        @authenticatable_name ||=
          self.class.name.split("::").last.underscore.sub("_authenticatable", "").to_sym
      end
    end
  end
end