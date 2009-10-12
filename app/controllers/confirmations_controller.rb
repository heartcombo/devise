class ConfirmationsController < ApplicationController
  before_filter :is_devise_resource?

  # GET /confirmation/new
  #
  def new
  end

  # POST /confirmation
  #
  def create
    self.resource = resource_class.send_confirmation_instructions(params[resource_name])

    if resource.errors.empty?
      set_flash_message :success, :send_instructions
      redirect_to new_session_path(resource_name)
    else
      render :new
    end
  end

  # GET /confirmation?perishable_token=abcdef
  #
  def show
    self.resource = resource_class.confirm!(:perishable_token => params[:perishable_token])

    if resource.errors.empty?
      set_flash_message :success, :confirmed
      redirect_to new_session_path(resource_name)
    else
      render :new
    end
  end
end
