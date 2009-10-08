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

require 'devise/models/authenticable'
require 'devise/models/confirmable'
require 'devise/models/recoverable'
require 'devise/models/validatable'

ActionController::Base.send :include, Devise::Controllers::Authenticable
ActionView::Base.send :include, DeviseHelper
