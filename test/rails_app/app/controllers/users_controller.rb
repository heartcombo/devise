class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    user_session[:cart] = "Cart"
  end
end
