source "http://rubygems.org"

gemspec

gem "rails", "~> 3.2.6"
gem "omniauth", "~> 1.0.0"
gem "omniauth-oauth2", "~> 1.0.0"
gem "rdoc"

group :test do
  gem "omniauth-facebook"
  gem "omniauth-openid", "~> 1.0.1"
  gem "webrat", "0.7.2", :require => false
  gem "mocha", :require => false

  platforms :mri_18 do
    gem "ruby-debug", ">= 0.10.3"
  end
  platforms :mri_19 do
    gem 'debugger'
  end
end

platforms :jruby do
  gem "activerecord-jdbc-adapter"
  gem "activerecord-jdbcsqlite3-adapter"
  gem "jruby-openssl"
end

platforms :ruby do
  gem "sqlite3"

  group :mongoid do
    gem "mongo", "~> 1.3.0"
    gem "mongoid", "~> 2.0"
    gem "bson_ext", "~> 1.3.0"
  end
end
