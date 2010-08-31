source "http://rubygems.org"

gem "rails", "3.0.0"

platforms :jruby do
  gem 'activerecord-jdbcsqlite3-adapter'
end

platforms :ruby do
  gem "sqlite3-ruby"
  if RUBY_VERSION < '1.9'
    gem "ruby-debug", ">= 0.10.3"
  end
  group :mongoid do
    gem "mongo"
    gem "mongoid", :git => "git://github.com/mongoid/mongoid.git"
    gem "bson_ext"
  end
end

gem "warden", "0.10.7"
gem "webrat", "0.7.0"
gem "mocha", :require => false
gem "bcrypt-ruby", :require => "bcrypt"
gem "oauth2"
