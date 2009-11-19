class SessionsController < ApplicationController
  include Devise::Controllers::Helpers

  before_filter :require_no_authentication, :only => [ :new, :create ]

  # GET /resource/sign_in
  def new
    Devise::FLASH_MESSAGES.each do |message|
      set_now_flash_message :failure, message if params.try(:[], message) == "true"
    end
    build_resource
  end

  # POST /resource/sign_in
  def create
    if authenticate(resource_name)
      set_flash_message :success, :signed_in
      sign_in_and_redirect(resource_name)
    else
      set_now_flash_message :failure, warden.message || :invalid
      build_resource
      render :new
    end
  end

  # GET /resource/sign_out
  def destroy
    set_flash_message :success, :signed_out if signed_in?(resource_name)
    sign_out_and_redirect(resource_name)
  end

end
