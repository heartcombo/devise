# frozen_string_literal: true

require 'devise/rails/routes'
require 'devise/rails/routes_loader'
require 'devise/rails/warden_compat'

module Devise
  class Engine < ::Rails::Engine
    config.devise = Devise

    # Initialize Warden and copy its configurations.
    config.app_middleware.use Warden::Manager do |config|
      Devise.warden_config = config
    end

    if defined?(::Rails::Engine::LazyRouteSet)
      # Load routes before Warden copies its config. See Devise::RoutesLoader.
      config.app_middleware.insert_before Warden::Manager, Devise::RoutesLoader

      # Rails only lazy-loads routes in development and test. Elsewhere routes are
      # drawn during initialization, and since `devise_for` needs to load the model
      # class to know which routes to draw, Rails 8.2+ warns about the model being
      # loaded too early whenever eager loading is off (e.g. rake tasks in
      # production). When eager loading is on, Rails loads routes at boot either
      # way, so it is safe to use lazy routes in every environment.
      initializer "devise.lazy_routes", after: :load_environment_config, before: :make_routes_lazy do |app|
        if app.config.route_set_class == ActionDispatch::Routing::RouteSet
          app.config.route_set_class = ::Rails::Engine::LazyRouteSet
        end
      end
    end

    # Force routes to be loaded if we are doing any eager load.
    config.before_eager_load do |app|
      app.reload_routes! if Devise.reload_routes
    end

    initializer "devise.deprecator" do |app|
      app.deprecators[:devise] = Devise.deprecator if app.respond_to?(:deprecators)
    end

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
      Devise.secret_key ||= app.secret_key_base

      Devise.token_generator ||=
        if secret_key = Devise.secret_key
          Devise::TokenGenerator.new(
            ActiveSupport::CachingKeyGenerator.new(ActiveSupport::KeyGenerator.new(secret_key))
          )
        end
    end

    initializer "devise.configure_zeitwerk" do
      if Rails.autoloaders.zeitwerk_enabled? && !defined?(ActionMailer)
        Rails.autoloaders.main.ignore("#{root}/app/mailers/devise/mailer.rb")
      end
    end
  end
end
