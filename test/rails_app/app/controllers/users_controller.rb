class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    user_session[:cart] = "Cart"
  end

  def expire
    user_session['last_request_at'] = 31.minutes.ago.utc
    render :text => 'User will be expired on next request'
  end

  def show
    render :text => current_user.id.to_s
  end
end
