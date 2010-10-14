require 'devise/rails/routes'
require 'devise/rails/warden_compat'

module Devise
  class Engine < ::Rails::Engine
    config.devise = Devise

    # Skip eager load of controllers because it is handled by Devise
    # to avoid loading unused controllers.
    target = paths.is_a?(Hash) ? paths["app/controllers"] : paths.app.controllers
    target.autoload!
    target.skip_eager_load!

    # Initialize Warden and copy its configurations.
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
      Devise.include_helpers(Devise::Controllers)
    end

    initializer "devise.oauth_url_helpers" do
      if Devise.oauth_configs.any?
        Devise.include_helpers(Devise::Oauth)
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

    initializer "devise.encryptor_check" do
      case Devise.encryptor
      when :bcrypt
        puts "[DEVISE] From version 1.2, there is no need to set your encryptor to bcrypt " <<
          "since encryptors are only enabled if you include :encryptable in your models. " << 
          "With this change, we can integrate better with bcrypt and get rid of the " <<
          "password_salt column (since bcrypt stores the salt with password). " <<
          "Please comment config.encryptor in your initializer to get rid of this warning."
      when nil
        # Nothing to say
      else
        puts "[DEVISE] You are using #{Devise.encryptor} as encryptor. From version 1.2, " <<
          "you need to explicitly add `devise :encryptable, :encryptor => #{Devise.encryptor.to_sym}` " <<
          "to your models and comment the current value in the config/initializers/devise.rb"
      end
    end

    # Check all available mappings and only load related controllers.
    def eager_load!
      mappings    = Devise.mappings.values.map(&:modules).flatten.uniq
      controllers = Devise::CONTROLLERS.values_at(*mappings)
      path        = paths.is_a?(Hash) ? paths["app/controllers"].first : paths.app.controllers.first
      matcher     = /\A#{Regexp.escape(path)}\/(.*)\.rb\Z/

      Dir.glob("#{path}/devise/{#{controllers.join(',')}}_controller.rb").sort.each do |file|
        require_dependency file.sub(matcher, '\1')
      end

      super
    end
  end
end
