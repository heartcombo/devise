require 'devise/rails/routes'
require 'devise/rails/warden_compat'

module Devise
  class Engine < ::Rails::Engine
    config.devise = Devise

    # Skip eager load of controllers because it is handled by Devise
    # to avoid loading unused controllers.
    config.paths.app.controllers.autoload!
    config.paths.app.controllers.skip_eager_load!

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
      if Devise.oauth_providers.any?
        Devise.include_helpers(Devise::Oauth)
      end
    end

    # Check all available mapings and only load related controllers.
    def eager_load!
      mappings    = Devise.mappings.values.map(&:modules).flatten.uniq
      controllers = Devise::CONTROLLERS.values_at(*mappings)
      path        = paths.app.controllers.to_a.first
      matcher     = /\A#{Regexp.escape(path)}\/(.*)\.rb\Z/

      Dir.glob("#{path}/devise/{#{controllers.join(',')}}_controller.rb").sort.each do |file|
        require_dependency file.sub(matcher, '\1')
      end

      super
    end
  end
end