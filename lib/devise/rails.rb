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

    initializer "devise.auth_keys" do
      if Devise.authentication_keys.size > 1
        puts "[DEVISE] You are configuring Devise to use more than one authentication key. " \
          "In previous versions, we automatically added #{Devise.authentication_keys[1..-1].inspect} " \
          "as scope to your e-mail validation, but this was changed now. If you were relying in such " \
          "behavior, you should remove :validatable from your models and add the validations manually. " \
          "To get rid of this warning, you can comment config.authentication_keys in your initializer " \
          "and pass the current values as key to the devise call in your model."
      end
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
  end
end
