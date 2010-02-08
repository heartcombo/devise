class RegistrationsController < ApplicationController
  include Devise::Controllers::InternalHelpers
  include Devise::Controllers::Common

  # POST /resource/registration
  def create
    self.resource = resource_class.new(params[resource_name])

    if resource.save
      flash[:"#{resource_name}.signed_up"] = true
      set_flash_message :notice, :signed_up
      sign_in_and_redirect(resource_name, resource)
    else
      render_with_scope :new
    end
  end
end
