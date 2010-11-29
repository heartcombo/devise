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
          "you need to explicitly add `devise :encryptable, :encryptor => :#{Devise.encryptor}` " <<
          "to your models and comment the current value in the config/initializers/devise.rb"
      end
    end
  end
end
