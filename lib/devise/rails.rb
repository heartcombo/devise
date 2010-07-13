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
      ActiveSupport.on_load(:action_controller) do
        include Devise::Controllers::Helpers
        include Devise::Controllers::UrlHelpers
      end

      ActiveSupport.on_load(:action_view) do
        include Devise::Controllers::UrlHelpers
      end
    end

    initializer "devise.oauth_url_helpers" do
      if Devise.oauth_providers.any?
        ActiveSupport.on_load(:action_controller) { include Devise::Oauth::UrlHelpers }
        ActiveSupport.on_load(:action_view) { include Devise::Oauth::UrlHelpers }
      end
    end
  end
end