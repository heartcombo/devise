class SessionsController < ApplicationController
  before_filter :authenticate!, :except => :new
  before_filter :require_no_authentication, :only => :new

  # GET /session/new
  #
  def new
  end

  # POST /session
  #
  def create
    redirect_to root_path if authenticated?
  end

  # DELETE /session
  #
  def destroy
    redirect_to new_session_path if logout
  end
end
