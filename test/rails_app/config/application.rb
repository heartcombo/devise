require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "rails/test_unit/railtie"

Bundler.require :default, DEVISE_ORM

begin
  require "#{DEVISE_ORM}/railtie"
rescue LoadError
end

require "devise"

module RailsApp
  class Application < Rails::Application
    # Add additional load paths for your own custom dirs
    config.load_paths.reject!{ |p| p =~ /\/app\/(\w+)$/ && !%w(controllers helpers views).include?($1) }
    config.load_paths += [ "#{config.root}/app/#{DEVISE_ORM}" ]

    # Configure generators values. Many other options are available, be sure to check the documentation.
    # config.generators do |g|
    #   g.orm             :active_record
    #   g.template_engine :erb
    #   g.test_framework  :test_unit, :fixture => true
    # end

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters << :password

    # Cookie settings
    config.cookie_secret = 'ea942c41850d502f2c8283e26bdc57829f471bb18224ddff0a192c4f32cdf6cb5aa0d82b3a7a7adbeb640c4b06f3aa1cd5f098162d8240f669b39d6b49680571'
    config.session_store :cookie_store, :key => "_my_app"
  end
end
