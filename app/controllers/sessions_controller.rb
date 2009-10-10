class SessionsController < ApplicationController
  before_filter :authenticate!, :only => :destroy
  before_filter :require_no_authentication, :except => :destroy

  # GET /session/new
  #
  def new
  end

  # POST /session
  #
  def create
    if authenticate
      flash[:notice] = I18n.t(:signed_in, :scope => [:devise, :sessions], :default => 'Signed in successfully.')
      redirect_to root_path
    else
      render :new
    end
  end

  # DELETE /session
  #
  def destroy
    logout
    flash[:notice] = I18n.t(:signed_out, :scope => [:devise, :sessions], :default => 'Signed out successfully.')
    redirect_to new_session_path
  end
end
