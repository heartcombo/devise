source "http://rubygems.org"

gemspec

gem "rails", "~> 3.0.4"
gem "oa-oauth", '~> 0.2.0', :require => "omniauth/oauth"
gem "oa-openid", '~> 0.2.0', :require => "omniauth/openid"

group :test do
  gem "webrat", "0.7.2", :require => false
  gem "mocha", :require => false
end

platforms :jruby do
  gem 'activerecord-jdbcsqlite3-adapter'
end

platforms :ruby do
  group :test do
    gem "sqlite3-ruby"
    gem "ruby-debug", ">= 0.10.3" if RUBY_VERSION < '1.9'
  end

  group :mongoid do
    gem "mongo", "~> 1.3.0"
    gem "mongoid", "2.0.1"
    gem "bson_ext", "~> 1.3.0"
  end
end
