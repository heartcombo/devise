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

class ActionController::Base
  include Devise::Controllers::Authenticable
end
