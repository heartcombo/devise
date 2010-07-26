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

      def stub!(provider, stubs=nil, &block)
        raise "You either need to pass stubs as a block or as a parameter" unless block_given? || stubs
        stubs ||= Faraday::Adapter::Test::Stubs.new(&block)
        Devise.oauth_configs[provider].build_connection do |b|
          b.adapter :test, stubs
        end
      end

      def reset_stubs!(*providers)
        target = providers.any? ? Devise.oauth_configs.slice(*providers) : Devise.oauth_configs
        target.each_value do |v|
          v.build_connection { |b| b.adapter Faraday.default_adapter }
        end
      end
    end
  end
end