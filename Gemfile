source "https://rubygems.org"

gemspec

gem "rails", "~> 4.0.0.rc1"
gem "omniauth", "~> 1.0.0"
gem "omniauth-oauth2", "~> 1.0.0"
gem "rdoc"

group :test do
  gem "omniauth-facebook"
  gem "omniauth-openid", "~> 1.0.1"
  gem "webrat", "0.7.3", :require => false
  gem "mocha", "~> 0.13.1", :require => false
end

platforms :jruby do
  gem "activerecord-jdbc-adapter"
  gem "activerecord-jdbcsqlite3-adapter"
  gem "jruby-openssl"
end

platforms :ruby do
  gem "sqlite3"
end

platforms :mri_19, :mri_20 do
  group :mongoid do
    gem "mongoid", github: "mongoid/mongoid", branch: "master"
  end
end
