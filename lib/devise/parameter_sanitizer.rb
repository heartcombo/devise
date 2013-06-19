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
    private

    def fallback_for(kind)
      if respond_to?(kind, true)
        send(kind)
      else
        raise NotImplementedError, "Devise Parameter Sanitizer doesn't know how to sanitize parameters for #{kind}"
      end
    end

    def sign_in
      default_params.permit(*auth_keys)
    end

    def sign_up
      default_params.permit(*(auth_keys + [:password, :password_confirmation]))
    end

    def account_update
      default_params.permit(*(auth_keys + [:password, :password_confirmation, :current_password]))
    end

    def auth_keys
      resource_class.authentication_keys
    end
  end
end
