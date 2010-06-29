class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => :accept
  respond_to :html, :xml

  def index
    user_session[:cart] = "Cart"
    respond_with(current_user)
  end

  def accept
    @current_user = current_user
  end

  def expire
    user_session['last_request_at'] = 31.minutes.ago.utc
    render :text => 'User will be expired on next request'
  end
end
