begin
  require "omniauth/core"
rescue LoadError => e
  warn "Could not load 'omniauth/core'. Please ensure you have the oa-core gem installed and listed in your Gemfile."
  raise
end

unless OmniAuth.config.respond_to? :test_mode
  warn "Devise's OmniAuth testing support is deprecated. You should use Omniauth's own support, please ensure you have 0.2.0.beta version or later installed."
end

# Clean up the default path_prefix. It will be automatically set by Devise.
OmniAuth.config.path_prefix = nil

OmniAuth.config.on_failure = Proc.new do |env|
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
