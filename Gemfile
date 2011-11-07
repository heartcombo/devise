source "http://rubygems.org"

gemspec

gem "rails", "~> 3.1.0"
gem 'omniauth', '~> 1.0.0'
gem 'omniauth-oauth2', '~> 1.0.0'
gem "rdoc"

group :test do
  gem "webrat", "0.7.2", :require => false
  gem "mocha", :require => false
  gem 'omniauth-facebook' #, '~> 1.0.0'
end

platforms :jruby do
  gem 'activerecord-jdbc-adapter'
  gem 'activerecord-jdbcsqlite3-adapter'
  gem 'jruby-openssl'
end

platforms :mri_18 do
  group :test do
    gem "ruby-debug", ">= 0.10.3"
  end
end

platforms :ruby do
  gem "sqlite3-ruby"

  group :mongoid do
    gem "mongo", "~> 1.3.0"
    gem "mongoid", "~> 2.0"
    gem "bson_ext", "~> 1.3.0"
  end
end
