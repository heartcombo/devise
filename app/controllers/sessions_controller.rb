class SessionsController < ApplicationController
  before_filter :is_devise_resource?
  before_filter :require_no_authentication, :only => [ :new, :create ]

  # GET /resource/sign_in
  def new
    unauthenticated! if params[:unauthenticated]
  end

  # POST /resource/sign_in
  def create
    if authenticate(resource_name)
      set_flash_message :success, :signed_in
      redirect_back_or_to root_path
    else
      unauthenticated!
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
      flash.now[:failure] = I18n.t(:"#{resource_name}.unauthenticated",
                                   :scope => [:devise, :sessions], :default => :unauthenticated)
    end
end
