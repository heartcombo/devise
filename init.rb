require 'devise'

# Configures a preparation callback to include devise authenticable module and
# view helpers (engines don't load helpers by default)
#config.to_prepare do
#  ActionController::Base.send :include, Devise::Controllers::Authenticable
#  ActionView::Base.send :include, DeviseHelper
##  ApplicationController.helper(DeviseHelper)
#end
