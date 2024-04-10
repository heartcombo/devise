# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "rails", "~> 7.1.0"
gem "omniauth"
gem "omniauth-oauth2"
gem "rdoc"

gem "rails-controller-testing", github: "rails/rails-controller-testing"

gem "responders", "~> 3.1"

group :test do
  gem "omniauth-facebook"
  gem "omniauth-openid"
  gem "rexml"
  gem "timecop"
  gem "webrat", "0.7.3", require: false
  gem "mocha", "~> 2.1", require: false
end

platforms :ruby do
  gem "sqlite3"
end

group :mongoid do
  gem "mongoid", "~> 8.1"
end
