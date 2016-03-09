source "https://rubygems.org"

gemspec

gem "rails", "~> 4.2.5"
gem "omniauth", "~> 1.3"
gem "omniauth-oauth2", "~> 1.4"
gem "rdoc"

group :test do
  gem "omniauth-facebook"
  gem "omniauth-openid", "~> 1.0.1"
  gem "webrat", "0.7.3", require: false
  gem "mocha", "~> 1.1", require: false
end

platforms :jruby do
  gem "activerecord-jdbc-adapter"
  gem "activerecord-jdbcsqlite3-adapter"
  gem "jruby-openssl"
end

platforms :ruby do
  gem "sqlite3"
end

group :mongoid do
  gem "mongoid", "~> 4.0"
end
