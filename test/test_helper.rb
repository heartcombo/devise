# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
DEVISE_ORM = (ENV["DEVISE_ORM"] || :active_record).to_sym

$:.unshift File.dirname(__FILE__)
puts "\n==> Devise.orm = #{DEVISE_ORM.inspect}"

require "rails_app/config/environment"
require "rails/test_help"
require "orm/#{DEVISE_ORM}"

I18n.load_path.concat Dir["#{File.dirname(__FILE__)}/support/locale/*.yml"]
# Allow setting test-specific locales even if they are not defined in the locale YAML files.
I18n.enforce_available_locales = false

require 'mocha/minitest'
require 'timecop'
require 'webrat'
Webrat.configure do |config|
  config.mode = :rails
  config.open_error_files = false
end

if ActiveSupport.respond_to?(:test_order)
  ActiveSupport.test_order = :random
end

OmniAuth.config.logger = Logger.new('/dev/null')

# Add support to load paths so we can overwrite broken webrat setup
$:.unshift File.expand_path('../support', __FILE__)
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# For generators
require "rails/generators/test_case"
require "generators/devise/install_generator"
require "generators/devise/views_generator"
require "generators/devise/controllers_generator"
