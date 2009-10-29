class SessionsController < ApplicationController
  include Devise::Controllers::Helpers

  # Maps the messages types that comes from warden to a flash type.
  WARDEN_MESSAGES = {
    :unauthenticated => :success,
    :unconfirmed => :failure
  }

  before_filter :require_no_authentication, :only => [ :new, :create ]

  # GET /resource/sign_in
  def new
    WARDEN_MESSAGES.each do |message, type|
      set_now_flash_message type, message if params.key?(message)
    end
    build_resource
  end

  # POST /resource/sign_in
  def create
    if authenticate(resource_name)
      set_flash_message :success, :signed_in
      redirect_back_or_to home_or_root_path
    else
      set_now_flash_message :failure, :invalid
      build_resource
      render :new
    end
  end

  # GET /resource/sign_out
  def destroy
    set_flash_message :success, :signed_out if signed_in?(resource_name)
    sign_out(resource_name)
    redirect_to root_path
  end

end
