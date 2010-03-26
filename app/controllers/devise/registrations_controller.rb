class Devise::RegistrationsController < ApplicationController
  prepend_before_filter :require_no_authentication, :only => [ :new, :create ]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy]
  include Devise::Controllers::InternalHelpers

  # GET /resource/sign_up
  def new
    build_resource
    render_with_scope :new
  end

  # POST /resource/sign_up
  def create
    build_resource

    if resource.save
      flash[:"#{resource_name}_signed_up"] = true
      set_flash_message :notice, :signed_up
      sign_in_and_redirect(resource_name, resource)
    else
      render_with_scope :new
    end
  end

  # GET /resource/edit
  def edit
    render_with_scope :edit
  end

  # PUT /resource
  def update
    if resource.update_with_password(params[resource_name])
      set_flash_message :notice, :updated
      redirect_to after_sign_in_path_for(self.resource)
    else
      render_with_scope :edit
    end
  end

  # DELETE /resource
  def destroy
    resource.destroy
    set_flash_message :notice, :destroyed
    sign_out_and_redirect(self.resource)
  end

  protected

    # Authenticates the current scope and gets a copy of the current resource.
    # We need to use a copy because we don't want actions like update changing
    # the current user in place.
    def authenticate_scope!
      send(:"authenticate_#{resource_name}!")
      self.resource = resource_class.find(send(:"current_#{resource_name}").id)
    end
end
