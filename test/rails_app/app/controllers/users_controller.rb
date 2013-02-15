class UsersController < ApplicationController
  prepend_before_filter :current_user, :only => :exhibit
  before_filter :authenticate_user!, :except => [:accept, :exhibit]
  respond_to :html, :xml

  def index
    user_session[:cart] = "Cart"
    respond_with(current_user)
  end

  def accept
    @current_user = current_user
  end

  def exhibit
    render :text => current_user ? "User is authenticated" : "User is not authenticated"
  end

  def expire
    user_session['last_request_at'] = 31.minutes.ago.utc
    render :text => 'User will be expired on next request'
  end

  def clear_timeout
    user_session['last_request_at'] = nil
    render :text => 'User will be expired on next request'
  end
end
