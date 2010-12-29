# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :current_user
  before_filter :authenticate_user!, :if => :devise_controller?
end
