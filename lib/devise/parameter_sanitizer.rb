module Devise
  class BaseSanitizer
    attr_reader :params, :resource_name, :resource_class

    def initialize(resource_class, resource_name, params)
      @resource_class = resource_class
      @resource_name  = resource_name
      @params         = params
      @blocks         = Hash.new
    end

    def for(kind, &block)
      if block_given?
        @blocks[kind] = block
      else
        block = @blocks[kind]
        block ? block.call(default_params) : fallback_for(kind)
      end
    end

    private

    def fallback_for(kind)
      default_params
    end

    def default_params
      params.fetch(resource_name, {})
    end
  end

  class ParameterSanitizer < BaseSanitizer

    class PermittedParameters

      def initialize(resource_class)
        @resource_class = resource_class
        @for = { :sign_in => sign_in, :sign_up => sign_up, :account_update => account_update }
      end

      def sign_in
        auth_keys + [:password, :remember_me]
      end

      def sign_up
        auth_keys + [:password, :password_confirmation]
      end

      def account_update
        auth_keys + [:password, :password_confirmation, :current_password]
      end

      def auth_keys
        @resource_class.authentication_keys.respond_to?(:keys) ? @resource_class.authentication_keys.keys : @resource_class.authentication_keys
      end

      def for(kind)
        @for[kind]
      end

      def add(*params)
        @for.each { |action, permitted| permitted.push *params }
      end

      def remove(*params)
        @for.each do |action, permitted| 
          permitted.delete_if { |param| params.include? param }
        end
      end

    end

    def permitted_parameters
      @permitted_parameters ||= PermittedParameters.new(@resource_class)
    end

    private

    def fallback_for(kind)
      if respond_to?(kind, true)
        send(kind)
      elsif (permitted = permitted_parameters.for(kind))
        default_params.permit permitted
      else
        raise NotImplementedError, "Devise Parameter Sanitizer doesn't know how to sanitize parameters for #{kind}"
      end
    end

  end
end
