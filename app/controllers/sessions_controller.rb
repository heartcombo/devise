class SessionsController < ApplicationController
  before_filter :authenticate!, :except => :new
  before_filter :require_no_authentication, :only => :new

  def new
  end

  def create
    redirect_to root_path if authenticated?
  end

  def destroy
    redirect_to :action => :new if logout
  end
end
