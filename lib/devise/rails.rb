require 'devise/rails/routes'
require 'devise/rails/warden_compat'

module Devise
  class Engine < ::Rails::Engine
    config.devise = Devise

    # Initialize Warden and copy its configurations.
    config.app_middleware.use Warden::Manager do |config|
      Devise.warden_config = config
    end

    # Force routes to be loaded if we are doing any eager load.
    config.before_eager_load { |app| app.reload_routes! }

    initializer "devise.url_helpers" do
      Devise.include_helpers(Devise::Controllers)
    end

    initializer "devise.omniauth", after: :load_config_initializers, before: :build_middleware_stack do |app|
      Devise.omniauth_configs.each do |provider, config|
        app.middleware.use config.strategy_class, *config.args do |strategy|
          config.strategy = strategy
        end
      end

      if Devise.omniauth_configs.any?
        Devise.include_helpers(Devise::OmniAuth)
      end
    end

    initializer "devise.secret_key" do |app|
      if app.respond_to?(:secrets)
        Devise.secret_key ||= app.secrets.secret_key_base
      elsif app.config.respond_to?(:secret_key_base)
        Devise.secret_key ||= app.config.secret_key_base
      end

      Devise.token_generator ||=
        if secret_key = Devise.secret_key
          Devise::TokenGenerator.new(
            ActiveSupport::CachingKeyGenerator.new(ActiveSupport::KeyGenerator.new(secret_key))
          )
        end
    end

    initializer "devise.fix_routes_proxy_missing_respond_to_bug" do
      # Deprecate: Remove once we move to Rails 4 only.
      ActionDispatch::Routing::RoutesProxy.class_eval do
        def respond_to?(method, include_private = false)
          super || routes.url_helpers.respond_to?(method)
        end
      end
    end
  end
end
