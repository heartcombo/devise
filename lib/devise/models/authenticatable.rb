require 'devise/hooks/activatable'
require 'devise/models/serializable'

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
    #   * +skip_session_storage+: By default Devise will store the user in session.
    #     You can skip storage for http and token auth by appending values to array:
    #     :skip_session_storage => [:token_auth] or :skip_session_storage => [:http_auth, :token_auth],
    #     by default is set to :skip_session_storage => [:http_auth].
    #
    # == active_for_authentication?
    #
    # After authenticating a user and in each request, Devise checks if your model is active by
    # calling model.active_for_authentication?. This method is overwriten by other devise modules. For instance,
    # :confirmable overwrites .active_for_authentication? to only return true if your model was confirmed.
    #
    # You overwrite this method yourself, but if you do, don't forget to call super:
    #
    #   def active_for_authentication?
    #     super && special_condition_is_valid?
    #   end
    #
    # Whenever active_for_authentication? returns false, Devise asks the reason why your model is inactive using
    # the inactive_message method. You can overwrite it as well:
    #
    #   def inactive_message
    #     special_condition_is_valid? ? super : :special_condition_is_not_valid
    #   end
    #
    module Authenticatable
      extend ActiveSupport::Concern

      include Devise::Models::Serializable

      included do
        class_attribute :devise_modules, :instance_writer => false
        self.devise_modules ||= []

        before_validation :downcase_keys
        before_validation :strip_whitespace
      end

      # Check if the current object is valid for authentication. This method and
      # find_for_authentication are the methods used in a Warden::Strategy to check
      # if a model should be signed in or not.
      #
      # However, you should not overwrite this method, you should overwrite active_for_authentication?
      # and inactive_message instead.
      def valid_for_authentication?
        block_given? ? yield : true
      end

      def active_for_authentication?
        true
      end

      def inactive_message
        :inactive
      end

      def authenticatable_salt
      end

      def devise_mailer
        Devise.mailer
      end

      def headers_for(name)
        {}
      end

      def downcase_keys
        (self.class.case_insensitive_keys || []).each { |k| self[k].try(:downcase!) }
      end

      def strip_whitespace
        (self.class.strip_whitespace_keys || []).each { |k| self[k].try(:strip!) }
      end

      module ClassMethods
        Devise::Models.config(self, :authentication_keys, :request_keys, :strip_whitespace_keys,
          :case_insensitive_keys, :http_authenticatable, :params_authenticatable, :skip_session_storage)

        def serialize_into_session(record)
          [record.to_key, record.authenticatable_salt]
        end

        def serialize_from_session(key, salt)
          record = to_adapter.get(key)
          record if record && record.authenticatable_salt == salt
        end

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
          find_first_by_auth_conditions(conditions)
        end

        def find_first_by_auth_conditions(conditions)
          to_adapter.find_first devise_param_filter.filter(conditions)
        end

        # Find an initialize a record setting an error if it can't be found.
        def find_or_initialize_with_error_by(attribute, value, error=:invalid) #:nodoc:
          find_or_initialize_with_errors([attribute], { attribute => value }, error)
        end

        # Find an initialize a group of attributes based on a list of required attributes.
        def find_or_initialize_with_errors(required_attributes, attributes, error=:invalid) #:nodoc:
          attributes = attributes.slice(*required_attributes)
          attributes.delete_if { |key, value| value.blank? }

          if attributes.size == required_attributes.size
            record = find_first_by_auth_conditions(attributes)
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

        protected

        def devise_param_filter
          @devise_param_filter ||= Devise::ParamFilter.new(case_insensitive_keys, strip_whitespace_keys)
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