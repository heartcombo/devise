require 'devise/rails/routes'
require 'devise/rails/warden_compat'

# Include UrlHelpers in ActionController and ActionView as soon as they are loaded.
ActiveSupport.on_load(:action_controller) { include Devise::Controllers::UrlHelpers }
ActiveSupport.on_load(:action_view) { include Devise::Controllers::UrlHelpers }

module Devise
  class Engine < ::Rails::Engine
    config.devise = Devise

    config.app_middleware.use Warden::Manager do |config|
      Devise.warden_config = config
    end

    # Force routes to be loaded if we are doing any eager load.
    config.before_eager_load { |app| app.reload_routes! }

    config.after_initialize do
      flash = [:unauthenticated, :unconfirmed, :invalid, :invalid_token, :timeout, :inactive, :locked]

      translations = begin
        I18n.available_locales
        I18n.backend.send(:translations)
      rescue Exception => e # Do not care if something fails
        {}
      end

      translations.each do |locale, translations|
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