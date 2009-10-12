class SessionsController < ApplicationController
  before_filter :find_resource_class

  # GET /session/sign_in
  # TODO Test me
  def new
    set_flash_message :failure, params[:message].to_sym, true if params[:message]
  end

  # POST /session/sign_in
  def create
    if warden.authenticate(:scope => resource_name)
      set_flash_message :success, :signed_in
      redirect_to root_path
    else
      set_flash_message :failure, :unauthenticated, true
      render :new
    end
  end

  # GET /session/sign_out
  # DELETE /session/sign_out
  def destroy
    logout(resource_name)
    set_flash_message :success, :signed_out
    redirect_to new_session_path
  end
end
