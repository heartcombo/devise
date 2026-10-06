# frozen_string_literal: true

module Devise
  # Starting from Rails 8.0, routes are lazy-loaded and only drawn once a request
  # reaches the router. Devise configures Warden while routes are drawn (see
  # Devise::RouteSet#finalize!), but Warden runs earlier in the middleware stack
  # and copies its configuration when it builds the proxy for the request, so the
  # first request of a process would see a Warden with no default scope, no
  # strategies and no session serializers. This middleware sits right before
  # Warden::Manager and makes sure routes are loaded first. Devise.mappings does
  # the same for code paths that are not requests, such as tests and the console.
  class RoutesLoader #:nodoc:
    def initialize(app)
      @app = app
    end

    def call(env)
      Rails.application.reload_routes_unless_loaded
      @app.call(env)
    end
  end
end
