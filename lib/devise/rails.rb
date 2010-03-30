require 'devise/rails/routes'
require 'devise/rails/warden_compat'

module Devise
  class Engine < ::Rails::Engine
    config.devise = Devise

    initializer "devise.add_middleware" do |app|
      app.config.middleware.use Warden::Manager do |config|
        Devise.configure_warden(config)
      end
    end

    initializer "devise.add_url_helpers" do |app|
      Devise::FailureApp.send :include, app.routes.url_helpers
    end
  end
end