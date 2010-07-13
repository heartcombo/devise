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
  end
end