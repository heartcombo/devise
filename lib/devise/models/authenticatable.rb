require 'devise/hooks/activatable'

module Devise
  module Models
    # Authenticable module. Holds common settings for authentication.
    #
    # == Configuration:
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
    # == Active?
    #
    # Before authenticating an user and in each request, Devise checks if your model is active by
    # calling model.active?. This method is overwriten by other devise modules. For instance,
    # :confirmable overwrites .active? to only return true if your model was confirmed.
    #
    # You overwrite this method yourself, but if you do, don't forget to call super:
    #
    #   def active?
    #     super && special_condition_is_valid?
    #   end
    #
    # Whenever active? returns false, Devise asks the reason why your model is inactive using
    # the inactive_message method. You can overwrite it as well:
    #
    #   def inactive_message
    #     special_condition_is_valid? ? super : :special_condition_is_not_valid
    #   end
    #
    module Authenticatable
      extend ActiveSupport::Concern

      included do
        class_attribute :devise_modules, :instance_writer => false
        self.devise_modules ||= []
      end

      # Check if the current object is valid for authentication. This method and
      # find_for_authentication are the methods used in a Warden::Strategy to check
      # if a model should be signed in or not.
      #
      # However, you should not overwrite this method, you should overwrite active? and
      # inactive_message instead.
      def valid_for_authentication?
        if active?
          block_given? ? yield : true
        else
          inactive_message
        end
      end

      def active?
        true
      end

      def inactive_message
        :inactive
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

        # By default discards all information sent by the session by calling
        # new with params.
        def new_with_session(params, session)
          new(params)
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

        # Find an initialize a record setting an error if it can't be found.
        def find_or_initialize_with_error_by(attribute, value, error=:invalid) #:nodoc:
          if value.present?
            conditions = { attribute => value }
            record = find(:first, :conditions => conditions)
          end

          unless record
            record = new
            if value.present?
              record.send(:"#{attribute}=", value)
            else
              error = :blank
            end
            record.errors.add(attribute, error)
          end

          record
        end

        # Generate a token by looping and ensuring does not already exist.
        def generate_token(column)
          loop do
            token = Devise.friendly_token
            break token unless find(:first, :conditions => { column => token })
          end
        end
      end
    end
  end
end