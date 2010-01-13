class PasswordsController < ApplicationController
  include Devise::Controllers::InternalHelpers
  include Devise::Controllers::Common

  before_filter :require_no_authentication

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    self.resource = resource_class.new
    resource.reset_password_token = params[:reset_password_token]
    render_with_scope :edit
  end

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password!(params[resource_name])

    if resource.errors.empty?
      set_flash_message :success, :updated
      sign_in_and_redirect(resource_name, resource)
    else
      render_with_scope :edit
    end
  end

  protected

    def send_instructions_with
      :send_reset_password_instructions
    end
end
