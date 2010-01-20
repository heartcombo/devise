class ConfirmationsController < ApplicationController
  include Devise::Controllers::InternalHelpers
  include Devise::Controllers::Common

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm!(:confirmation_token => params[:confirmation_token])

    if resource.errors.empty?
      set_flash_message :notice, :confirmed
      sign_in_and_redirect(resource_name, resource)
    else
      render_with_scope :new
    end
  end

  protected

    def send_instructions_with
      :send_confirmation_instructions
    end
end
