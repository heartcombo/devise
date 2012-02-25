begin
  require "omniauth"
  require "omniauth/version"
rescue LoadError => e
  warn "Could not load 'omniauth'. Please ensure you have the omniauth gem >= 1.0.0 installed and listed in your Gemfile."
  raise
end

unless OmniAuth::VERSION =~ /^1\./
  raise "You are using an old OmniAuth version, please ensure you have 1.0.0.pr2 version or later installed."
end

original_omniauth_failure_app = OmniAuth.config.on_failure

OmniAuth.config.on_failure = Proc.new do |env|
  req = Rack::Request.new(env)
  if req.session[:omni_devise_mapping]
    env['devise.mapping'] = Devise.mappings[req.session[:omni_devise_mapping]]
    controller_name  = ActiveSupport::Inflector.camelize(env['devise.mapping'].controllers[:omniauth_callbacks])
    controller_klass = ActiveSupport::Inflector.constantize("#{controller_name}Controller")
    controller_klass.action(:failure).call(env)
  else
    original_omniauth_failure_app.call(env)
  end
end

module Devise
  module OmniAuth
    autoload :Config,      "devise/omniauth/config"
    autoload :UrlHelpers,  "devise/omniauth/url_helpers"
  end
end
