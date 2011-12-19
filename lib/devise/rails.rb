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

    initializer "devise.deprecations" do
      if Devise.case_insensitive_keys == false
        warn "\n[DEVISE] Devise.case_insensitive_keys is false which is no longer " \
          "supported. If you want to continue running on this mode, please ensure " \
          "you are not using validatable (you can copy the validations directly to your model) " \
          "and set case_insensitive_keys to an empty array."
      end

      if Devise.apply_schema && defined?(Mongoid)
        warn "\n[DEVISE] Devise.apply_schema is true. This means Devise was " \
          "automatically configuring your DB. This no longer happens. You should " \
          "set Devise.apply_schema to false and manually set the fields used by Devise as shown here: " \
          "https://github.com/plataformatec/devise/wiki/How-To:-Upgrade-to-Devise-2.0-migration-schema-style"
      end

      # TODO: Deprecate the true value of this option as well
      if Devise.use_salt_as_remember_token == false
        warn "\n[DEVISE] Devise.use_salt_as_remember_token is false which is no longer " \
          "supported. Devise now only uses the salt as remember token and the remember_token " \
          "column can be removed from your models."
      end

      if Devise.reset_password_within.nil?
        warn "\n[DEVISE] Devise.reset_password_within is nil. Please set this value to " \
          "an interval (for example, 6.hours) and add a reset_password_sent_at field to " \
          "your Devise models (if they don't have one already)."
      end
    end
  end
end
