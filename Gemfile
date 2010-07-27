source "http://rubygems.org"

if File.exist? File.expand_path('../../rails', __FILE__)
  gem "rails", :path => "../rails"
else
  gem "rails", :git => "git://github.com/rails/rails.git"
end

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
    gem "mongoid", :git => "git://github.com/durran/mongoid.git"
    gem "bson_ext"
  end
end

gem "warden", "0.10.7"
gem "webrat", "0.7.0"
gem "mocha", :require => false
gem "bcrypt-ruby", :require => "bcrypt"
gem "oauth2"
