require 'devise/rails/routes'
require 'devise/rails/warden_compat'

module Devise
  class Engine < ::Rails::Engine
    config.devise = Devise

    initializer "devise.ensure_routes_are_loaded", :before => :load_app_classes, :after => :load_config_initializers do |app|
      app.reload_routes!
    end

    initializer "devise.add_middleware" do |app|
      app.config.middleware.use Warden::Manager do |config|
        Devise.warden_config = config
        Devise.configure_warden!
      end
    end

    initializer "devise.add_url_helpers" do |app|
      Devise::FailureApp.send :include, app.routes.url_helpers
      ActionController::Base.send :include, Devise::Controllers::UrlHelpers
      ActionView::Base.send :include, Devise::Controllers::UrlHelpers
    end

    config.after_initialize do
      I18n.available_locales
      flash = [:unauthenticated, :unconfirmed, :invalid, :invalid_token, :timeout, :inactive, :locked]

      I18n.backend.send(:translations).each do |locale, translations|
        keys = flash & (translations[:devise][:sessions].keys) rescue []

        if keys.any?
          ActiveSupport::Deprecation.warn "The following I18n messages in 'devise.sessions' " <<
            "for locale '#{locale}' are deprecated: #{keys.to_sentence}. Please move them to " <<
            "'devise.failure' instead."
        end
      end
    end
  end
end