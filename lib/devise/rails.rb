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
      Devise.encryptor ||= begin
        warn "[WARNING] config.encryptor is not set in your config/initializers/devise.rb. " \
          "Devise will then set it to :bcrypt. If you were using the previous default " \
          "encryptor, please add config.encryptor = :sha1 to your configuration file." if Devise.mailer_sender
        :bcrypt
      end
    end

    unless Rails.env.production?
      config.after_initialize do
        actions = [:confirmation_instructions, :reset_password_instructions, :unlock_instructions]

        translations = begin
          I18n.t("devise.mailer", :raise => true).map { |k, v| k if v.is_a?(String) }.compact
        rescue Exception => e # Do not care if something fails
          []
        end

        keys = actions & translations

        keys.each do |key|
          ActiveSupport::Deprecation.warn "The I18n message 'devise.mailer.#{key}' is deprecated. " \
            "Please use 'devise.mailer.#{key}.subject' instead."
        end
      end

      config.after_initialize do
        flash = [:unauthenticated, :unconfirmed, :invalid, :invalid_token, :timeout, :inactive, :locked]

        translations = begin
          I18n.t("devise.sessions", :raise => true).keys
        rescue Exception => e # Do not care if something fails
          []
        end

        keys = flash & translations

        if keys.any?
          ActiveSupport::Deprecation.warn "The following I18n messages in 'devise.sessions' " \
            "are deprecated: #{keys.to_sentence}. Please move them to 'devise.failure' instead."
        end
      end
    end
  end
end