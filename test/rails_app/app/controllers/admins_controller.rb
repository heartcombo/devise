class AdminsController < ApplicationController
  before_filter :admin_authenticate!

  def index
  end
end
