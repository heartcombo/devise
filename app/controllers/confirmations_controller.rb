class ConfirmationsController < ApplicationController
  include Devise::Controllers::Helpers

  # GET /resource/confirmation/new
  def new
    build_resource
  end

  # POST /resource/confirmation
  def create
    self.resource = resource_class.send_confirmation_instructions(params[resource_name])

    if resource.errors.empty?
      set_flash_message :success, :send_instructions
      redirect_to new_session_path(resource_name)
    else
      render :new
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm!(:confirmation_token => params[:confirmation_token])

    if resource.errors.empty?
      set_flash_message :success, :confirmed
      sign_in_and_redirect(resource_name, resource)
    else
      render :new
    end
  end
end
