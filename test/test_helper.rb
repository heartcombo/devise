require 'rubygems'

ENV["RAILS_ENV"] = "test"
DEVISE_ORM = (ENV["DEVISE_ORM"] || :active_record).to_sym
require File.join(File.dirname(__FILE__), 'orm', DEVISE_ORM.to_s)

require 'webrat'
require 'mocha'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = 'test.com'

Webrat.configure do |config|
  config.mode = :rails
  config.open_error_files = false
end