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

if RUBY_VERSION < '1.9'
  gem "ruby-debug", ">= 0.10.3"
end

group :mongoid do
  gem "mongo"
  gem "mongoid", :git => "git://github.com/durran/mongoid.git"
  gem "bson_ext"
end

group :data_mapper do
  gem 'dm-core',           '~> 1.0.0', :git => 'git://github.com/datamapper/dm-core'
  gem 'dm-migrations',     '~> 1.0.0', :git => 'git://github.com/datamapper/dm-migrations'
  gem 'dm-sqlite-adapter', '~> 1.0.0', :git => 'git://github.com/datamapper/dm-sqlite-adapter'
  gem 'dm-validations',    '~> 1.0.0', :git => 'git://github.com/datamapper/dm-validations'
  gem 'dm-serializer',     '~> 1.0.0', :git => 'git://github.com/datamapper/dm-serializer'
  gem 'dm-timestamps',     '~> 1.0.0', :git => 'git://github.com/datamapper/dm-timestamps'
  gem 'dm-rails',          '~> 1.0.0', :git => 'git://github.com/datamapper/dm-rails'
end
