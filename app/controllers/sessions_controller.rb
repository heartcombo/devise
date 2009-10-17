class SessionsController < ApplicationController
  before_filter :is_devise_resource?
  before_filter :require_no_authentication, :only => [ :new, :create ]

  # GET /session/sign_in
  def new
    unauthenticated! if params[:unauthenticated]
  end

  # POST /session/sign_in
  def create
    if sign_in(resource_name)
      set_flash_message :success, :signed_in
      redirect_back_or_to root_path
    else
      unauthenticated!
      render :new
    end
  end

  # GET /session/sign_out
  # DELETE /session/sign_out
  def destroy
    set_flash_message :success, :signed_out if signed_in?(resource_name)
    sign_out(resource_name)
    redirect_to root_path
  end

  protected

    def unauthenticated!
      flash.now[:failure] = I18n.t(:"#{resource_name}.unauthenticated",
                                   :scope => [:devise, :sessions], :default => :unauthenticated)
    end
end
