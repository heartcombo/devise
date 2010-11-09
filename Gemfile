source "http://rubygems.org"

gemspec

gem "rails"
gem "webrat", "0.7.1"
gem "mocha", :require => false
gem "oa-oauth", :require => "omniauth/oauth"
gem "oa-openid", :require => "omniauth/openid"

platforms :jruby do
  gem 'activerecord-jdbcsqlite3-adapter'
end

platforms :ruby do
  gem "sqlite3-ruby"
  gem "ruby-debug", ">= 0.10.3" if RUBY_VERSION < '1.9'

  group :mongoid do
    gem "mongo", "1.0.7"
    gem "mongoid", "2.0.0.beta.18"
    gem "bson_ext", "1.0.7"
  end
end