module Devise
  class ParameterSanitizer
    attr_reader :allowed_params

    # Return a list of parameter names permitted to be mass-assigned for the
    # passed controller.
    def permitted_params_for(controller_name)
      allowed_params.fetch(key_for_controller_name(controller_name), [])
    end

    # Set up a new parameter sanitizer with a set of allowed parameters. This
    # gets initialized on each request so that parameters may be augmented or
    # changed as needed via before_filter.
    def initialize
      @allowed_params = {
        :confirmations_controller => [:email],
        :passwords_controller => authentication_keys + [:password, :password_confirmation, :reset_password_token],
        :registrations_controller => authentication_keys + [:password, :password_confirmation, :current_password],
        :sessions_controller => authentication_keys + [:password],
        :unlocks_controller => [:email]
      }
    end

    # Allow additional parameters for a Devise controller. If the
    # controller_name doesn't exist in allowed_params, it will be added to it
    # as an empty array and param_name will be appended to that array. Note
    # that when adding a new controller, use the full controller name
    # (:confirmations_controller) and not the short names
    # (:confirmation/:confirmations).
    def permit_devise_param(controller_name, param_name)
      @allowed_params[key_for_controller_name(controller_name)] << param_name
      true
    end

    # Remove specific allowed parameter for a Devise controller. If the
    # controller_name doesn't exist in allowed_params, it will be added to it
    # as an empty array.
    def remove_permitted_devise_param(controller_name, param_name)
      @allowed_params[key_for_controller_name(controller_name)].delete(param_name)
      true
    end

    protected

    def authentication_keys
      Array(::Devise.authentication_keys)
    end

    # Flexibly allow access to permitting/denying/checking parameters by
    # controller name in the following key formats: :confirmations_controller,
    # :confirmations, :confirmation
    def key_for_controller_name(name)
      if allowed_params.has_key?(name.to_sym)
        name.to_sym
      elsif allowed_params.has_key?(:"#{name}s_controller")
        :"#{name}s_controller"
      elsif allowed_params.has_key?(:"#{name}_controller")
        :"#{name}_controller"
      else
        @allowed_params[name.to_sym] = []
        name.to_sym
      end
    end
  end
end
