begin
  require "omniauth/core"
rescue LoadError => e
  warn "Could not load 'omniauth/core'. Please ensure you have the oa-core gem installed and listed in your Gemfile."
  raise
end

unless OmniAuth.config.respond_to? :test_mode
  raise "You are using an old OmniAuth version, please ensure you have 0.2.0.beta version or later installed."
end

# Clean up the default path_prefix. It will be automatically set by Devise.
OmniAuth.config.path_prefix = nil

OmniAuth.config.on_failure = Proc.new do |env|
  env['devise.mapping'] = Devise::Mapping.find_by_path!(env['PATH_INFO'], :path)
  controller_name  = ActiveSupport::Inflector.camelize(env['devise.mapping'].controllers[:omniauth_callbacks])
  controller_klass = ActiveSupport::Inflector.constantize("#{controller_name}Controller")
  controller_klass.action(:failure).call(env)
end

module Devise
  module OmniAuth
    autoload :Config,      "devise/omniauth/config"
    autoload :UrlHelpers,  "devise/omniauth/url_helpers"
  end
end
