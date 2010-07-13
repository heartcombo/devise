require 'devise/rails/routes'
require 'devise/rails/warden_compat'

module Devise
  class Engine < ::Rails::Engine
    config.devise = Devise

    config.app_middleware.use Warden::Manager do |config|
      Devise.warden_config = config
    end

    # Force routes to be loaded if we are doing any eager load.
    config.before_eager_load { |app| app.reload_routes! }

    initializer "devise.add_filters" do |app|
      app.config.filter_parameters += [:password, :password_confirmation]
      app.config.filter_parameters.uniq
    end

    initializer "devise.url_helpers" do
      Devise.include_helpers(Devise::Controllers)
    end

    initializer "devise.oauth_url_helpers" do
      if Devise.oauth_providers.any?
        Devise.include_helpers(Devise::Oauth)
      end
    end
  end
end