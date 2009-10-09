begin
  require 'warden'
rescue
  gem 'hassox-warden'
  require 'warden'
end

begin
  require 'rails_warden'
rescue
  gem 'hassox-rails_warden'
  require 'rails_warden'
end

require 'devise/initializers/warden'

module Devise
end

ActionView::Base.send :include, DeviseHelper
ActionController::Base.send :include, Devise::Controllers::Authenticable
#ActiveRecord::Base.send :include, Devise
