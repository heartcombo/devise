class RegistrationsController < ApplicationController
  include Devise::Controllers::InternalHelpers
  include Devise::Controllers::Common

  # POST /resource/registration
  def create
    self.resource = resource_class.new(params[resource_name])

    if resource.save
      # Attempt to sign the resource in. When there is no other thing blocking
      # the resource (ie confirmations), then the resource will be signed in,
      # otherwise the specific message is shown and the resource will be
      # redirected to the sign in page.
      sign_in(resource_name, resource)
      # At this time the resource has signed in and no hook has signed it out.
      set_flash_message :notice, :signed_up
      sign_in_and_redirect(resource_name, resource, true)
    else
      render_with_scope :new
    end
  end
end
