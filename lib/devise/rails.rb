require 'devise/rails/routes'
require 'devise/rails/warden_compat'

Rails.configuration.after_initialize do
  require "devise/orm/#{Devise.orm}"

  # Adds Warden Manager to Rails middleware stack, configuring default devise
  # strategy and also the failure app.
  Rails.configuration.middleware.use Warden::Manager do |manager|
    Devise.configure_warden_manager(manager)
  end

  # If using a rememberable module, include the middleware that log users.
  Rails.configuration.middleware.use Devise::Middlewares::Rememberable

  I18n.load_path.unshift File.expand_path(File.join(File.dirname(__FILE__), 'locales', 'en.yml'))
end
