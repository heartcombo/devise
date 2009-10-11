class SessionsController < ApplicationController
  before_filter :authenticate!, :only => :destroy
  #before_filter :require_no_authentication, :except => :destroy

  # GET /session/new
  #
  def new
  end

  # POST /session
  #
  def create
    self.resource = resource_class.authenticate(params[resource_name])
    if resource #authenticate
      self.current_user = resource
      flash[:success] = I18n.t(:signed_in, :scope => [:devise, :sessions], :default => 'Signed in successfully.')
      redirect_to root_path
    else
      flash.now[:failure] = I18n.t(:authentication_failed, :scope => [:devise, :sessions], :default => 'Invalid email or password.')
      render :new
    end
  end

  # DELETE /session
  #
  def destroy
    logout
    flash[:success] = I18n.t(:signed_out, :scope => [:devise, :sessions], :default => 'Signed out successfully.')
    redirect_to new_session_path
  end
end
