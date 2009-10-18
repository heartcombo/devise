class UsersController < ApplicationController
  before_filter :sign_in_user!

  def index
    user_session[:cart] = "Cart"
  end
end
