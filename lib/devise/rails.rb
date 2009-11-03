require 'devise/rails/routes'
require 'devise/rails/warden_compat'

Rails.configuration.after_initialize do
  if defined?(ActiveRecord)
    ActiveRecord::Base.extend Devise::Models
    ActiveRecord::ConnectionAdapters::TableDefinition.send :include, Devise::Migrations
  end

  # Adds Warden Manager to Rails middleware stack, configuring default devise
  # strategy and also the failure app.
  Rails.configuration.middleware.use Warden::Manager do |manager|
    Devise.configure_warden_manager(manager)
  end

  I18n.load_path.unshift File.expand_path(File.join(File.dirname(__FILE__), 'locales', 'en.yml'))
end
