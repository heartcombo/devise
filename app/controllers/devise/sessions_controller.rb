class Devise::SessionsController < ApplicationController
  prepend_before_filter :require_no_authentication, :only => [ :new, :create ]
  include Devise::Controllers::InternalHelpers

  # GET /resource/sign_in
  def new
    clean_up_passwords(build_resource)
    render_with_scope :new
  end

  # POST /resource/sign_in
  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")

    # In the running app, the previous line would actually cause this method to
    # exit by throwing `:warden` if the authentication failed. Unfortunately,
    # this doesn't happen in the Rails test environment if you have included the
    # Devise::TestHelpers (see `Devise::TestHelpers::TestWarden#authenticate!`),
    # which makes it difficult to unit test extensions to this controller. Since
    # the resource is nil if authentication fails, just short-circuit the method
    # in that case. This should not affect the running app.
    
    return if resource.nil?

    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    respond_with resource, :location => redirect_location(resource_name, resource)
  end

  # GET /resource/sign_out
  def destroy
    signed_in = signed_in?(resource_name)
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message :notice, :signed_out if signed_in

    # We actually need to hardcode this, as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.any(*navigational_formats) { redirect_to after_sign_out_path_for(resource_name) }
      format.all do
        method = "to_#{request_format}"
        text = {}.respond_to?(method) ? {}.send(method) : ""
        render :text => text, :status => :ok
      end
    end
  end
end
