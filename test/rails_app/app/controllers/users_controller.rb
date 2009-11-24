class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    user_session[:cart] = "Cart"
  end

  def new
    user_session['last_request_at'] = 31.minutes.ago.utc
    render :text => 'New user!'
  end

  def edit
    user_session['last_request_at'] = 29.minutes.ago.utc
    render :text => 'Edit user!'
  end
end
