class UsersController < ApplicationController
  before_filter :sign_in_user!

  def index
  end
end
