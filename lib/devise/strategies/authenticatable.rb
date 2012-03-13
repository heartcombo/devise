require 'devise/strategies/base'

module Devise
  module Strategies
    # This strategy should be used as basis for authentication strategies. It retrieves
    # parameters both from params or from http authorization headers. See database_authenticatable
    # for an example.
    class Authenticatable < Base
      attr_accessor :authentication_hash, :authentication_type, :password

      def store?
        !mapping.to.skip_session_storage.include?(authentication_type)
      end

      def valid?
        valid_for_params_auth? || valid_for_http_auth?
      end

    private

      # Simply invokes valid_for_authentication? with the given block and deal with the result.
      def validate(resource, &block)
        result = resource && resource.valid_for_authentication?(&block)

        case result
        when Symbol, String
          ActiveSupport::Deprecation.warn "valid_for_authentication should return a boolean value"
          fail!(result)
          return false
        end

        if result
          decorate(resource)
          true
        else
          if resource
            fail!(resource.unauthenticated_message)
          end
          false
        end
      end

      # Get values from params and set in the resource.
      def decorate(resource)
        resource.remember_me = remember_me? if resource.respond_to?(:remember_me=)
      end

      # Should this resource be marked to be remembered?
      def remember_me?
        valid_params? && Devise::TRUE_VALUES.include?(params_auth_hash[:remember_me])
      end

      # Check if this is strategy is valid for http authentication by:
      #
      #   * Validating if the model allows params authentication;
      #   * If any of the authorization headers were sent;
      #   * If all authentication keys are present;
      #
      def valid_for_http_auth?
        http_authenticatable? && request.authorization && with_authentication_hash(:http_auth, http_auth_hash)
      end

      # Check if this is strategy is valid for params authentication by:
      #
      #   * Validating if the model allows params authentication;
      #   * If the request hits the sessions controller through POST;
      #   * If the params[scope] returns a hash with credentials;
      #   * If all authentication keys are present;
      #
      def valid_for_params_auth?
        params_authenticatable? && valid_params_request? &&
          valid_params? && with_authentication_hash(:params_auth, params_auth_hash)
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

      # By default, a request is valid if the controller set the proper env variable.
      def valid_params_request?
        !!env["devise.allow_params_authentication"]
      end

      # If the request is valid, finally check if params_auth_hash returns a hash.
      def valid_params?
        params_auth_hash.is_a?(Hash)
      end

      # Check if password is present and is not equal to "X" (default value for token).
      def valid_password?
        password.present? && password != "X"
      end

      # Helper to decode credentials from HTTP.
      def decode_credentials
        return [] unless request.authorization && request.authorization =~ /^Basic (.*)/m
        Base64.decode64($1).split(/:/, 2)
      end

      # Sets the authentication hash and the password from params_auth_hash or http_auth_hash.
      def with_authentication_hash(auth_type, auth_values)
        self.authentication_hash, self.authentication_type = {}, auth_type
        self.password = auth_values[:password]

        parse_authentication_key_values(auth_values, authentication_keys) &&
        parse_authentication_key_values(request_values, request_keys)
      end

      # Holds the authentication keys.
      def authentication_keys
        @authentication_keys ||= mapping.to.authentication_keys
      end

      # Holds request keys.
      def request_keys
        @request_keys ||= mapping.to.request_keys
      end

      # Returns values from the request object.
      def request_values
        keys = request_keys.respond_to?(:keys) ? request_keys.keys : request_keys
        values = keys.map { |k| self.request.send(k) }
        Hash[keys.zip(values)]
      end

      # Parse authentication keys considering if they should be enforced or not.
      def parse_authentication_key_values(hash, keys)
        keys.each do |key, enforce|
          value = hash[key].presence
          if value
            self.authentication_hash[key] = value
          else
            return false unless enforce == false
          end
        end
        true
      end

      # Holds the authenticatable name for this class. Devise::Strategies::DatabaseAuthenticatable
      # becomes simply :database.
      def authenticatable_name
        @authenticatable_name ||=
          ActiveSupport::Inflector.underscore(self.class.name.split("::").last).
            sub("_authenticatable", "").to_sym
      end
    end
  end
end
