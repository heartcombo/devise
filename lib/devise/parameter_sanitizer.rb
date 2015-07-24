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
        default_for(kind)
      end
    end

    def sanitize(kind)
      if block = @blocks[kind]
        block.call(default_params)
      else
        default_sanitize(kind)
      end
    end

    private

    def default_for(kind)
      raise ArgumentError, 'a block is expected in Devise base sanitizer'
    end

    def default_sanitize(kind)
      default_params
    end

    def default_params
      params.fetch(resource_name, {})
    end
  end

  class ParameterSanitizer < BaseSanitizer
    def initialize(*)
      super
      @permitted = Hash.new { |h,k| h[k] = attributes_for(k) }
    end

    def sign_in
      permit self.for(:sign_in)
    end

    def sign_up
      permit self.for(:sign_up)
    end

    def account_update
      permit self.for(:account_update)
    end

    private

    # TODO: We do need to flatten so it works with strong_parameters
    # gem. We should drop it once we move to Rails 4 only support.
    def permit(keys)
      default_params.permit(*Array(keys))
    end

    # Change for(kind) to return the values in the @permitted
    # hash, allowing the developer to customize at runtime.
    def default_for(kind)
      @permitted[kind] || raise("No sanitizer provided for #{kind}")
    end

    def default_sanitize(kind)
      if respond_to?(kind, true)
        send(kind)
      else
        raise NotImplementedError, "Devise doesn't know how to sanitize parameters for #{kind}"
      end
    end

    def attributes_for(kind)
      case kind
      when :sign_in
        auth_keys + [:password, :remember_me]
      when :sign_up
        auth_keys + [:password, :password_confirmation]
      when :account_update
        auth_keys + [:password, :password_confirmation, :current_password]
      end
    end

    def auth_keys
      @auth_keys ||= @resource_class.authentication_keys.respond_to?(:keys) ?
                       @resource_class.authentication_keys.keys : @resource_class.authentication_keys
    end
  end
end
