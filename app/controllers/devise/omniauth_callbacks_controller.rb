class Devise::OmniauthCallbacksController < ApplicationController
  include Devise::Controllers::InternalHelpers

  def failure
    set_flash_message :alert, :failure, :kind => failed_strategy.name.to_s.humanize, :reason => failure_message
    redirect_to after_omniauth_failure_path_for(resource_name)
  end

  protected

  def failed_strategy
    env["omniauth.failed_strategy"]
  end

  def failure_message
    exception = env["omniauth.error"]
    error   = exception.error_reason if exception.respond_to?(:error_reason)
    error ||= exception.error        if exception.respond_to?(:error)
    error ||= env["omniauth.failure_key"]
    error.to_s.humanize if error
  end

  def after_omniauth_failure_path_for(scope)
    new_session_path(scope)
  end

  #
  # Authenticate with the omniauth's data if the provider exist in the model
  #
  
  def method_missing(method_name, *args)
    if User.omniauth_providers.include? method_name
      authenticate_omniauth method_name
    else
      super method_name, *args
    end
  end
  
  def authenticate_omniauth(provider_name)
    user = User.find_for_omniauth( env["omniauth.auth"], current_user )
    if user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      sign_in_and_redirect user, :event => :authentication
    else
      session["devise.omniauth"] = env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

end
