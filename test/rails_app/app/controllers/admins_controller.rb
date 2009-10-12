class AdminsController < ApplicationController
  before_filter :sign_in_admin!

  def index
  end
end
