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

    initializer "devise.navigationals" do
      formats = Devise.navigational_formats
      if formats.include?(:"*/*") && formats.exclude?("*/*")
        puts "[DEVISE] We see the symbol :\"*/*\" in the navigational formats in your initializer " \
          "but not the string \"*/*\". Due to changes in latest Rails, please include the latter."
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
        puts "[DEVISE] From version 1.2, there is no need to set your encryptor to bcrypt " \
          "since encryptors are only enabled if you include :encryptable in your models. " \
          "To update your app, please:\n\n" \
          "1) Remove config.encryptor from your initializer;\n" \
          "2) Add t.encryptable to your old migrations;\n" \
          "3) [Optional] Remove password_salt in a new recent migration. Bcrypt does not require it anymore.\n"
      when nil
        # Nothing to say
      else
        puts "[DEVISE] You are using #{Devise.encryptor} as encryptor. From version 1.2, " \
          "you need to explicitly add encryptable as dependency. To update your app, please:\n\n" \
          "1) Remove config.encryptor from your initializer;\n" \
          "2) Add t.encryptable to your old migrations;\n" \
          "3) Add `devise :encryptable, :encryptor => :#{Devise.encryptor}` to your models.\n"
      end
    end
  end
end
