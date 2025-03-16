# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'omniauth'
gem 'omniauth-oauth2'
gem 'rails', '~> 8.0.0'
gem 'rdoc'

gem 'rails-controller-testing', github: 'rails/rails-controller-testing'

gem 'responders', '~> 3.1'

group :test do
  gem 'mocha', '~> 2.1', require: false
  gem 'omniauth-facebook'
  gem 'omniauth-openid'
  gem 'rexml'
  gem 'timecop'
  gem 'webrat', '0.7.3', require: false
end

platforms :ruby do
  gem 'sqlite3', '~> 2.1'
end

# platforms :jruby do
#   gem "activerecord-jdbc-adapter"
#   gem "activerecord-jdbcsqlite3-adapter"
#   gem "jruby-openssl"
# end

# TODO:
# group :mongoid do
#   gem "mongoid", "~> 4.0.0"
# end
