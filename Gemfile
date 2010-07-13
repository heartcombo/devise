source "http://rubygems.org"

if File.exist? File.expand_path('../../rails', __FILE__)
  gem "rails", :path => "../rails"
else
  gem "rails", :git => "git://github.com/rails/rails.git"
end

gem "warden", "0.10.7"
gem "sqlite3-ruby"
gem "webrat", "0.7.0"
gem "mocha", :require => false
gem "bcrypt-ruby", :require => "bcrypt"
gem "oauth2"

if RUBY_VERSION < '1.9'
  gem "ruby-debug", ">= 0.10.3"
end

group :mongoid do
  gem "mongo"
  gem "mongoid", :git => "git://github.com/durran/mongoid.git"
  gem "bson_ext"
end