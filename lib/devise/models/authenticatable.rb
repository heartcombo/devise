module Devise
  module Models
    # Authenticable module. Holds common settings for authentication.
    #
    # Configuration:
    #
    # You can overwrite configuration values by setting in globally in Devise,
    # using devise method or overwriting the respective instance method.
    #
    #   authentication_keys: parameters used for authentication. By default [:email].
    #
    #   http_authenticatable: if this model allows http authentication. By default true.
    #   It also accepts an array specifying the strategies that should allow http.
    #
    #   params_authenticatable: if this model allows authentication through request params. By default true.
    #   It also accepts an array specifying the strategies that should allow params authentication.
    #
    module Authenticatable
      extend ActiveSupport::Concern

      # Yields the given block. This method is overwritten by other modules to provide
      # hooks around authentication.
      def valid_for_authentication?
        yield
      end

      module ClassMethods
        Devise::Models.config(self, :authentication_keys, :http_authenticatable, :params_authenticatable)

        def params_authenticatable?(strategy)
          params_authenticatable.is_a?(Array) ?
            params_authenticatable.include?(strategy) : params_authenticatable
        end

        def http_authenticatable?(strategy)
          http_authenticatable.is_a?(Array) ?
            http_authenticatable.include?(strategy) : http_authenticatable
        end

        # Find first record based on conditions given (ie by the sign in form).
        # Overwrite to add customized conditions, create a join, or maybe use a
        # namedscope to filter records while authenticating.
        # Example:
        #
        #   def self.find_for_authentication(conditions={})
        #     conditions[:active] = true
        #     super
        #   end
        #
        def find_for_authentication(conditions)
          find(:first, :conditions => conditions)
        end
      end
    end
  end
end