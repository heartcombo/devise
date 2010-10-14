source "http://rubygems.org"

gemspec

gem "rails", "3.0.0"
gem "webrat", "0.7.1"
gem "mocha", :require => false
gem "oauth2"

platforms :jruby do
  gem 'activerecord-jdbcsqlite3-adapter'
end

platforms :ruby do
  gem "sqlite3-ruby"
  if RUBY_VERSION < '1.9'
    gem "ruby-debug", ">= 0.10.3"
  end
  group :mongoid do
    gem "mongo", "1.0.7"
    gem "mongoid", "2.0.0.beta.18"
    gem "bson_ext", "1.0.7"
  end
end