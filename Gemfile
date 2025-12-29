# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "omniauth"
gem "omniauth-oauth2"
gem "rails", "~> 8.1.0"
gem "rdoc"

gem "rails-controller-testing"

gem "responders", "~> 3.1"

group :test do
  gem "minitest", "< 6"
  gem "mocha", "~> 2.1", require: false
  gem "omniauth-facebook"
  gem "omniauth-openid"
  gem "rexml"
  gem "timecop"
  gem "webrat"
  gem "ostruct"
end

platforms :ruby do
  gem "sqlite3"
end

group :mongoid do
  gem "mongoid", "~> 9.0", github: "mongodb/mongoid", branch: "9.0-stable"
end
