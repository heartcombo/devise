require 'devise/rails/routes'
require 'devise/rails/warden_compat'

module Devise
  class Engine < ::Rails::Engine
    engine_name :devise

    config.middleware.use Warden::Manager do |config|
      Devise.configure_warden(config)
    end

    initializer "devise.load_orm" do
      require "devise/orm/#{Devise.orm}"
    end
  end
end