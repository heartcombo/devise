class PasswordsController < ApplicationController
  before_filter :is_devise_resource?, :require_no_authentication

  # GET /resource/password/new
  def new
  end

  # POST /resource/password
  def create
    self.resource = resource_class.send_reset_password_instructions(params[resource_name])

    if resource.errors.empty?
      set_flash_message :success, :send_instructions
      redirect_to new_session_path(resource_name)
    else
      render :new
    end
  end

  # GET /resource/password/edit?perishable_token=abcdef
  def edit
    self.resource = resource_class.new
    resource.perishable_token = params[:perishable_token]
  end

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password!(params[resource_name])

    if resource.errors.empty?
      set_flash_message :success, :updated
      redirect_to new_session_path(resource_name)
    else
      render :edit
    end
  end
end
