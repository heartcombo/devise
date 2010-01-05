require 'devise/rails/routes'
require 'devise/rails/warden_compat'

Rails.configuration.after_initialize do
  require "devise/orm/#{Devise.orm}"

  # Adds Warden Manager to Rails middleware stack, configuring default devise
  # strategy and also the failure app.
  Rails.configuration.middleware.use Warden::Manager do |config|
    Devise.configure_warden(config)
  end

  I18n.load_path.unshift File.expand_path(File.join(File.dirname(__FILE__), 'locales', 'en.yml'))
end
