ENV["RAILS_ENV"] = "test"
DEVISE_ORM = (ENV["DEVISE_ORM"] || :active_record).to_sym

puts "\n==> Devise.orm = #{DEVISE_ORM.inspect}"

require File.expand_path('../rails_app/config/application', __FILE__)
require File.expand_path("../orm/#{DEVISE_ORM}", __FILE__)

require 'mocha'

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = 'test.com'

Webrat.configure do |config|
  config.mode = :rails
  config.open_error_files = false
end

# Add support to load paths so we can overwrite broken webrat setup
$:.unshift File.expand_path('../support', __FILE__)
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }