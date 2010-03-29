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
    #
    module Authenticatable
      extend ActiveSupport::Concern

      module ClassMethods
        Devise::Models.config(self, :authentication_keys, :http_authenticatable)

        alias :http_authenticatable? :http_authenticatable

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