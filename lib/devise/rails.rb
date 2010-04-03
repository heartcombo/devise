require 'devise/rails/routes'
require 'devise/rails/warden_compat'

module Devise
  class Engine < ::Rails::Engine
    config.devise = Devise

    initializer "devise.add_middleware" do |app|
      app.config.middleware.use Warden::Manager do |config|
        Devise.warden_config = config
        config.failure_app   = Devise::FailureApp
        config.default_scope = Devise.default_scope
      end
    end

    initializer "devise.add_url_helpers" do |app|
      Devise::FailureApp.send :include, app.routes.url_helpers
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