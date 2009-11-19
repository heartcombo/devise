class PasswordsController < ApplicationController
  include Devise::Controllers::Helpers

  before_filter :require_no_authentication

  # GET /resource/password/new
  def new
    build_resource
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

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    self.resource = resource_class.new
    resource.reset_password_token = params[:reset_password_token]
  end

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password!(params[resource_name])

    if resource.errors.empty?
      set_flash_message :success, :updated
      sign_in_and_redirect(resource_name, resource)
    else
      render :edit
    end
  end
end
