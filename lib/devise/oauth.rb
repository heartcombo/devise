begin
  require "oauth2"
rescue LoadError => e
  warn "Could not load 'oauth2'. Please ensure you have the gem installed and listed in your Gemfile."
  raise
end

module Devise
  module Oauth
    autoload :Config,          "devise/oauth/config"
    autoload :Helpers,         "devise/oauth/helpers"
    autoload :InternalHelpers, "devise/oauth/internal_helpers"
    autoload :UrlHelpers,      "devise/oauth/url_helpers"
    autoload :TestHelpers,     "devise/oauth/test_helpers"

    class << self
      delegate :short_circuit_authorizers!, :unshort_circuit_authorizers!, :to => "Devise::Oauth::TestHelpers"

      def test_mode!
        Faraday.default_adapter = :test
        ActiveSupport.on_load(:action_controller) { include Devise::Oauth::TestHelpers }
        ActiveSupport.on_load(:action_view) { include Devise::Oauth::TestHelpers }
      end
    end
  end
end