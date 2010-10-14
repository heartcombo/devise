begin
  require "omniauth/core"
rescue LoadError => e
  warn "Could not load 'omniauth/core'. Please ensure you have the oa-core gem installed and listed in your Gemfile."
  raise
end

module OmniAuth
  module Strategy
    # TODO HAX Backport to OmniAuth
    def initialize(app, name, *args)
      @app = app
      @name = name.to_sym
      yield self if block_given?
    end
  end
end

# Clean up the default path_prefix. It will be automatically set by Devise.
OmniAuth.config.path_prefix = nil

module Devise
  module OmniAuth
    autoload :Config,      "devise/omniauth/config"
    autoload :UrlHelpers,  "devise/omniauth/url_helpers"
    autoload :TestHelpers, "devise/omniauth/test_helpers"

    class << self
      delegate :short_circuit_authorizers!, :unshort_circuit_authorizers!, :to => "Devise::OmniAuth::TestHelpers"

      def test_mode!
        Faraday.default_adapter = :test if defined?(Faraday)
        ActiveSupport.on_load(:action_controller) { include Devise::OmniAuth::TestHelpers }
        ActiveSupport.on_load(:action_view) { include Devise::OmniAuth::TestHelpers }
      end

      def stub!(provider, stubs=nil, &block)
        raise "You either need to pass stubs as a block or as a parameter" unless block_given? || stubs

        config = Devise.omniauth_configs[provider]
        config.check_if_allow_stubs!

        stubs ||= Faraday::Adapter::Test::Stubs.new(&block)
        config.build_connection do |b|
          b.adapter :test, stubs
        end
      end

      def reset_stubs!(*providers)
        target = providers.any? ? Devise.omniauth_configs.slice(*providers) : Devise.omniauth_configs
        target.each_value do |config|
          next unless config.allow_stubs?
          config.build_connection { |b| b.adapter Faraday.default_adapter }
        end
      end
    end
  end
end