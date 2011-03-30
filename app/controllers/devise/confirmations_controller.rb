class Devise::ConfirmationsController < ApplicationController
  include Devise::Controllers::InternalHelpers

  # GET /resource/confirmation/new
  def new
    build_resource({})
    render_with_scope :new
  end

  # POST /resource/confirmation
  def create
    self.resource = resource_class.send_confirmation_instructions(params[resource_name])

    if resource.errors.empty?
      set_flash_message(:notice, :send_instructions) if is_navigational_format?
      respond_with resource, :location => new_session_path(resource_name)
    else
      respond_with_navigational(resource){ render_with_scope :new }
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      set_flash_message(:notice, :confirmed) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with_navigational(resource){ redirect_to redirect_location(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render_with_scope :new }
    end
  end
end
