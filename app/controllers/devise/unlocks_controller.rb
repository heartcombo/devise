class Devise::UnlocksController < ApplicationController
  include Devise::Controllers::InternalHelpers

  before_filter :require_no_authentication

  # GET /resource/unlock/new
  def new
    build_resource
    render_with_scope :new
  end

  # POST /resource/unlock
  def create
    self.resource = resource_class.send_unlock_instructions(params[resource_name])

    if resource.errors.empty?
      set_flash_message :notice, :send_instructions
      redirect_to new_session_path(resource_name)
    else
      render_with_scope :new
    end
  end

  # GET /resource/unlock?unlock_token=abcdef
  def show
    self.resource = resource_class.unlock_access_by_token(params[:unlock_token])

    if resource.errors.empty?
      set_flash_message :notice, :unlocked
      sign_in_and_redirect(resource_name, resource)
    else
      render_with_scope :new
    end
  end
end
