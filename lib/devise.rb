begin
  require 'warden'
rescue
  gem 'hassox-warden'
  require 'warden'
end

require 'devise/initializers/warden'
require 'devise/mapping'

# Ensure to include Devise modules only after Rails initialization.
# This way application should have already defined Devise mappings and we are
# able to create default filters.
#
Rails.configuration.after_initialize do
  ActiveRecord::Base.extend Devise::ActiveRecord

  ActionController::Base.send :include, Devise::Controllers::Filters
  ActionController::Base.send :include, Devise::Controllers::Helpers
  ActionController::Base.send :include, Devise::Controllers::UrlHelpers

  ActionView::Base.send :include, Devise::Controllers::UrlHelpers
end
