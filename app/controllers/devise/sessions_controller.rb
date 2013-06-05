class Devise::SessionsController < DeviseController
  prepend_before_filter :require_no_authentication, :only => [ :new, :create ]
  prepend_before_filter :allow_params_authentication!, :only => :create

  # GET /resource/sign_in
  def new
    resource = build_resource(nil, :unsafe => true)
    clean_up_passwords(resource)
    respond_with(resource, serialize_options(resource))
  end

  # POST /resource/sign_in
  def create
    logger.debug("Authenticating in Warden...")
    resource = warden.authenticate!(auth_options)
    logger.debug("Warden authentication returned resource #{resource.inspect}.")
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    logger.debug("Signing the resource in with the name '#{resource_name}'...")
    sign_in(resource_name, resource)
    logger.debug("Sign-in of the resource '#{resource_name}' completed.")
    location = after_sign_in_path_for(resource)
    logger.debug("Redirecting to the after-sign-in path '#{location}'.")
    respond_with resource, :location => location
  end

  # DELETE /resource/sign_out
  def destroy
    redirect_path = after_sign_out_path_for(resource_name)
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message :notice, :signed_out if signed_out

    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.any(*navigational_formats) { redirect_to redirect_path }
      format.all do
        head :no_content
      end
    end
  end

  protected

  def serialize_options(resource)
    methods = resource_class.authentication_keys.dup
    methods = methods.keys if methods.is_a?(Hash)
    methods << :password if resource.respond_to?(:password)
    { :methods => methods, :only => [:password] }
  end

  def auth_options
    { :scope => resource_name, :recall => "#{controller_path}#new" }
  end
end

