# frozen_string_literal: true

class Devise::TwoFactorController < DeviseController
  include Devise::TwoFactor::PendingSignIn

  prepend_before_action :require_no_authentication
  prepend_before_action :set_authenticating_resource

  # Extensions can inject custom actions or override defaults via on_load
  ActiveSupport.run_load_hooks(:devise_two_factor_controller, self)

  # Auto-generate default new_<method> actions for each registered 2FA module.
  # Extensions that injected a custom action via on_load won't be overwritten.
  Devise.two_factor_method_configs.each_key do |mod|
    define_method(:"new_#{mod}") {} unless method_defined?(:"new_#{mod}")
  end

  # POST /users/two_factor
  # All methods POST here. Warden picks the right strategy via valid?.
  # Only 2FA strategies run, so a first-factor strategy can't take the request.
  def create
    self.resource = warden.authenticate!(*devise_mapping.two_factor_strategies, auth_options)
    set_flash_message!(:notice, :signed_in, scope: :"devise.sessions")
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  protected

  def auth_options
    default_method = @authenticating_resource.enabled_two_factors.first
    { scope: resource_name, recall: "#{controller_path}#new_#{default_method}" }
  end

  def translation_scope
    'devise.two_factor'
  end

  private

  def set_authenticating_resource
    @authenticating_resource = resource_from_pending_sign_in_for(resource_name)
    return if @authenticating_resource

    set_flash_message!(:alert, :sign_in_not_initiated, scope: :"devise.failure")
    redirect_to new_session_path(resource_name)
  end
end
