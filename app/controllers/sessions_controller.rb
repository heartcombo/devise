class SessionsController < ApplicationController
  include Devise::Controllers::Helpers

  before_filter :require_no_authentication, :only => [ :new, :create ]

  # GET /resource/sign_in
  def new
    unauthenticated! if params[:unauthenticated]
    unconfirmed!     if params[:unconfirmed]
    build_resource
  end

  # POST /resource/sign_in
  def create
    if authenticate(resource_name)
      set_flash_message :success, :signed_in
      redirect_back_or_to home_or_root_path
    else
      unauthenticated!
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

  protected

    def unauthenticated!
      set_now_flash_message :failure, :unauthenticated
    end

    def unconfirmed!
      set_now_flash_message :failure, :unconfirmed
    end

end
