# frozen_string_literal: true

class Devise::TwoFactorController < DeviseController
  prepend_before_action :require_no_authentication
  prepend_before_action :ensure_sign_in_initiated

  # Extensions can inject custom actions or override defaults via on_load
  ActiveSupport.run_load_hooks(:devise_two_factor_controller, self)

  # Auto-generate default new_<module> actions for each registered 2FA module.
  # Extensions that injected a custom action via on_load won't be overwritten.
  Devise.two_factor_method_configs.each_key do |mod|
    unless method_defined?(:"new_#{mod}")
      define_method(:"new_#{mod}") do
        @resource = find_pending_resource
      end
    end
  end

  # POST /users/two_factor
  # All methods POST here. Warden picks the right strategy via valid?.
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in, scope: :"devise.sessions")
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  protected

  def auth_options
    resource = find_pending_resource
    default_method = resource.enabled_two_factors.first
    { scope: resource_name, recall: "#{controller_path}#new_#{default_method}" }
  end

  def translation_scope
    'devise.two_factor'
  end

  def find_pending_resource
    return unless session[:devise_two_factor_resource_id]
    resource_class.where(id: session[:devise_two_factor_resource_id]).first
  end

  private

  def ensure_sign_in_initiated
    return if session[:devise_two_factor_resource_id].present?
    set_flash_message!(:alert, :sign_in_not_initiated, scope: :"devise.failure")
    redirect_to new_session_path(resource_name)
  end
end
