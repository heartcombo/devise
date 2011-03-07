require 'devise/hooks/activatable'

module Devise
  module Models
    # Authenticatable module. Holds common settings for authentication.
    #
    # == Options
    #
    # Authenticatable adds the following options to devise_for:
    #
    #   * +authentication_keys+: parameters used for authentication. By default [:email].
    #
    #   * +request_keys+: parameters from the request object used for authentication.
    #     By specifying a symbol (which should be a request method), it will automatically be
    #     passed to find_for_authentication method and considered in your model lookup.
    #
    #     For instance, if you set :request_keys to [:subdomain], :subdomain will be considered
    #     as key on authentication. This can also be a hash where the value is a boolean expliciting
    #     if the value is required or not.
    #
    #   * +http_authenticatable+: if this model allows http authentication. By default true.
    #     It also accepts an array specifying the strategies that should allow http.
    #
    #   * +params_authenticatable+: if this model allows authentication through request params. By default true.
    #     It also accepts an array specifying the strategies that should allow params authentication.
    #
    # == Active?
    #
    # Before authenticating a user and in each request, Devise checks if your model is active by
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

      def authenticatable_salt
      end

      module ClassMethods
        Devise::Models.config(self, :authentication_keys, :request_keys, :case_insensitive_keys, :http_authenticatable, :params_authenticatable)

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
          #the to_s is here to avoid mongodb injection where 'field => value' becomes 'field => {$ne => value}' thourgh the magic of rails
          #still this does not prevent the leak if user1.token == '$ne' + user2.token (the chance of that is poor though)
          #this might not be the best place or the best method, please change
          conditions.each do |k, v|
            conditions[k] = v.to_s
          end
          case_insensitive_keys.each { |k| conditions[k].try(:downcase!) }
          to_adapter.find_first(conditions)
        end

        # Find an initialize a record setting an error if it can't be found.
        def find_or_initialize_with_error_by(attribute, value, error=:invalid) #:nodoc:
          find_or_initialize_with_errors([attribute], { attribute => value }, error)
        end

        # Find an initialize a group of attributes based on a list of required attributes.
        def find_or_initialize_with_errors(required_attributes, attributes, error=:invalid) #:nodoc:
          case_insensitive_keys.each { |k| attributes[k].try(:downcase!) }
          
          attributes = attributes.slice(*required_attributes)
          attributes.delete_if { |key, value| value.blank? }

          if attributes.size == required_attributes.size
            record = to_adapter.find_first(attributes)
          end
          
          unless record
            record = new

            required_attributes.each do |key|
              value = attributes[key]
              record.send("#{key}=", value)
              record.errors.add(key, value.present? ? error : :blank)
            end
          end

          record
        end

        # Generate a token by looping and ensuring does not already exist.
        def generate_token(column)
          loop do
            token = Devise.friendly_token
            break token unless to_adapter.find_first({ column => token })
          end
        end
      end
    end
  end
end