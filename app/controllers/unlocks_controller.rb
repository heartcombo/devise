class UnlocksController < ApplicationController
  include Devise::Controllers::InternalHelpers
  include Devise::Controllers::Common

  # GET /resource/unlock?unlock_token=abcdef
  def show
    self.resource = resource_class.unlock!(:unlock_token => params[:unlock_token])

    if resource.errors.empty?
      set_flash_message :notice, :unlocked
      sign_in_and_redirect(resource_name, resource)
    else
      render_with_scope :new
    end
  end

  protected

    def send_instructions_with
      :send_unlock_instructions
    end
end
