begin
  require "omniauth/core"
rescue LoadError => e
  warn "Could not load 'omniauth/core'. Please ensure you have the oa-core gem installed and listed in your Gemfile."
  raise
end

module OmniAuth
  # TODO HAXES Backport to OmniAuth
  module Strategy #:nodoc:
    def initialize(app, name, *args)
      @app = app
      @name = name.to_sym
      yield self if block_given?
    end

    def fail!(message_key, exception = nil)
      self.env['omniauth.error'] = exception
      self.env['omniauth.failure_key'] = message_key
      self.env['omniauth.failed_strategy'] = self
      OmniAuth.config.on_failure.call(self.env, message_key.to_sym)
    end
  end
end

# Clean up the default path_prefix. It will be automatically set by Devise.
OmniAuth.config.path_prefix = nil

OmniAuth.config.on_failure = Proc.new do |env, key|
  env['devise.mapping'] = Devise::Mapping.find_by_path!(env['PATH_INFO'], :path)
  controller_klass = "#{env['devise.mapping'].controllers[:omniauth_callbacks].camelize}Controller"
  controller_klass.constantize.action(:failure).call(env)
end

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