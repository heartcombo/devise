class Devise::OmniauthAuthorizeController < DeviseController
  def show
    session[:omni_devise_mapping] = resource_name
    redirect_to "#{::OmniAuth.config.path_prefix}/#{params[:provider]}"
  end
end
