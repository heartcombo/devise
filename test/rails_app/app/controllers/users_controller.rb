class UsersController < ApplicationController
  before_filter :user_authenticate!

  def index
  end
end
