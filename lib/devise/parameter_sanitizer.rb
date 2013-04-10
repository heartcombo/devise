module Devise
  class BaseSanitizer
    attr_reader :params, :resource_name, :allowed_params

    def initialize(resource_name, params)
      @resource_name, @params = resource_name, params
      @allowed_params = {}
    end

    def default_params
      params.fetch(resource_name, {})
    end

    def sanitize_for(controller)
      default_params
    end
  end

  class ParameterSanitizer < BaseSanitizer
    # Return the allowed parameters passed through the StrongParametesr
    # require/permit step according to the allowed_params setup via
    # #permit, #permit!, #forbid, and any defaults.
    def sanitize_for(controller)
      permitted_params = allowed_params.fetch(param_key(controller), []).to_a

      params.require(resource_name).permit(permitted_params)
    end

    # Set up a new parameter sanitizer with a set of allowed parameters. This
    # gets initialized on each request so that parameters may be augmented or
    # changed as needed via before_filter.
    def initialize(resource_name, params)
      super
      @allowed_params = {
        :confirmations => [:email],
        :passwords     => auth_keys | [:password, :password_confirmation, :reset_password_token],
        :registrations => auth_keys | [:password, :password_confirmation, :current_password],
        :sessions      => auth_keys | [:password],
        :unlocks       => [:email]
      }
    end

    # Allow additional parameters for a Devise controller. If the
    # controller_name doesn't exist in allowed_params, it will be added to it
    # as an empty array and param_name will be appended to that array. Note
    # that when adding a new controller, use the full controller name
    # (:confirmations_controller) and not the short names
    # (:confirmation/:confirmations).
    def permit(controller_name, *param_names)
      @allowed_params[param_key(controller_name)] |= param_names
      true
    end

    def permit!(controller_name, *param_names)
      @allowed_params[param_key(controller_name)] = param_names
      true
    end

    # Remove specific allowed parameter for a Devise controller. If the
    # controller_name doesn't exist in allowed_params, it will be added to it
    # as an empty array.
    def forbid(controller_name, *param_names)
      @allowed_params[param_key(controller_name)] -= param_names
      true
    end

    protected

    def auth_keys
      Array(::Devise.authentication_keys)
    end

    # Flexibly allow access to permitting/denying/checking parameters by
    # controller name in the following key formats: :confirmations_controller,
    # :confirmations, :confirmation
    def param_key(controller_name)
      k = controller_name.to_sym

      if allowed_params.has_key?(k)
        k
      else
        @allowed_params[k] = []
        k
      end
    end
  end
end
