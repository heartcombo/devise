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

    initializer "devise.omniauth" do |app|
      Devise.omniauth_configs.each do |provider, config|
        app.middleware.use config.strategy_class, *config.args do |strategy|
          config.strategy = strategy
        end
      end

      if Devise.omniauth_configs.any?
        Devise.include_helpers(Devise::OmniAuth)
      end
    end

    initializer "devise.mongoid_version_warning" do
      if defined?(Mongoid)
        require 'mongoid/version'
        if Mongoid::VERSION.to_f < 2.1
          puts "\n[DEVISE] Please note that Mongoid versions prior to 2.1 handle dirty model " \
            "object attributes in such a way that the Devise `validatable` module will not apply " \
            "its usual uniqueness and format validations for the email field. It is recommended " \
            "that you upgrade to Mongoid 2.1+ for this and other fixes, but if for some reason you " \
            "are unable to do so, you should add these validations manually.\n"
        end
      end
    end

    initializer "devise.fix_routes_proxy_missing_respond_to_bug" do
      # We can get rid of this once we support Rails > 3.2
      ActionDispatch::Routing::RoutesProxy.class_eval do
        def respond_to?(method, include_private = false)
          super || routes.url_helpers.respond_to?(method)
        end
      end
    end

    initializer "devise.deprecations" do
      unless defined?(Rails::Generators)
        if Devise.case_insensitive_keys == false
          warn "\n[DEVISE] Devise.case_insensitive_keys is false which is no longer " \
            "supported. Recent Devise versions automatically downcase the e-mail before " \
            "saving it to the database but your app isn't using this feature. You can solve " \
            "this issue by either:\n\n" \
            "1) Setting config.case_insensitive_keys = [:email] in your Devise initializer and " \
            "running a migration that will downcase all emails already in the database;\n\n" \
            "2) Setting config.case_insensitive_keys = [] (so nothing will be downcased) and " \
            "making sure you are not using Devise :validatable (since validatable assumes case" \
            "insensitivity)\n"
        end

        if Devise.apply_schema && !defined?(Mongoid)
          warn "\n[DEVISE] Devise.apply_schema is true. This means Devise was " \
            "automatically configuring your DB. This no longer happens. You should " \
            "set Devise.apply_schema to false and manually set the fields used by Devise as shown here: " \
            "https://github.com/plataformatec/devise/wiki/How-To:-Upgrade-to-Devise-2.0-migration-schema-style\n"
        end

        # TODO: Deprecate the true value of this option as well
        if Devise.use_salt_as_remember_token == false
          warn "\n[DEVISE] Devise.use_salt_as_remember_token is false which is no longer " \
            "supported. Devise now only uses the salt as remember token and the remember_token " \
            "column can be removed from your models.\n"
        end

        if Devise.reset_password_within.nil?
          warn "\n[DEVISE] Devise.reset_password_within is nil. Please set this value to " \
            "an interval (for example, 6.hours) and add a reset_password_sent_at field to " \
            "your Devise models (if they don't have one already).\n"
        end
      end

      config.after_initialize do
        example = <<-YAML
en:
  devise:
    registrations:
      signed_up_but_unconfirmed: 'A message with a confirmation link has been sent to your email address. Please open the link to activate your account.'
      signed_up_but_inactive: 'You have signed up successfully. However, we could not sign you in because your account is not yet activated.'
      signed_up_but_locked: 'You have signed up successfully. However, we could not sign you in because your account is locked.'
        YAML

        if I18n.t(:"devise.registrations.reasons", :default => {}).present?
          warn "\n[DEVISE] devise.registrations.reasons in yml files is deprecated, " \
            "please use devise.registrations.signed_up_but_REASON instead. The default values are:\n\n#{example}\n"
        end

        if I18n.t(:"devise.registrations.inactive_signed_up", :default => "").present?
          warn "\n[DEVISE] devise.registrations.inactive_signed_up in yml files is deprecated, " \
            "please use devise.registrations.signed_up_but_REASON instead. The default values are:\n\n#{example}\n"
        end
      end
    end
  end
end
