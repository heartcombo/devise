# frozen_string_literal: true

# Boots the test app in a fresh process, makes the first request without
# touching Devise beforehand and reports what Warden was configured with.
# Run by test/lazy_routes_test.rb, which asserts on the JSON printed here. It
# lives outside test/support so that test_helper.rb does not require it.
#
# With DEVISE_PROBE_NON_LOCAL set, `Rails.env.local?` is false, as for a rake
# task in production. That stub has to go between loading the application and
# initializing it, which is why this does not require config/environment.rb.
ENV["RAILS_ENV"] = "test"

$:.unshift File.expand_path("..", __dir__)
require "rails_app/config/application"
require "rack/mock"

Rails.env.define_singleton_method(:local?) { false } if ENV["DEVISE_PROBE_NON_LOCAL"]

RailsApp::Application.initialize!

# Only meaningful with lazy routes (Rails 8+); nil before that.
routes_loaded = -> { Rails.application.routes_reloader.try(:loaded) }

result = {
  "lazy_route_set" => Rails.application.routes.class.name,
  "routes_loaded_after_boot" => routes_loaded.call,
  "user_model_loaded_after_boot" => $LOADED_FEATURES.any? { |f| f.end_with?("/rails_app/app/#{DEVISE_ORM}/user.rb") }
}

# Any path works: the Warden proxy is built before routing, and this one keeps
# the request away from the database.
env = Rack::MockRequest.env_for("/first-request-probe")
begin
  Rails.application.call(env)
rescue ActionController::RoutingError
end
warden = env["warden"]

result.merge!(
  "default_scope" => warden.config.default_scope.to_s,
  "user_strategies" => warden.config.default_strategies(scope: :user).map(&:to_s),
  "routes_loaded_after_request" => routes_loaded.call
)

puts "PROBE #{JSON.generate(result)}"
