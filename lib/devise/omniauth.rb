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
      delegate :short_circuit_authorizers!, :unshort_circuit_authorizers!,
        :test_mode!, :stub!, :reset_stubs!, :to => "Devise::OmniAuth::TestHelpers"
    end
  end
end