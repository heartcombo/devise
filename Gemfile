source "https://rubygems.org"

gemspec

gem "rails", "4.2.0.beta2"
gem "omniauth", "~> 1.2.0"
gem "omniauth-oauth2", "~> 1.1.0"
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
  gem "mongoid", github: "mongoid/mongoid", branch: "master"
end
