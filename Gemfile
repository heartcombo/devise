source "http://rubygems.org"

gemspec

gem "rails", "~> 3.1.0.rc8"
gem "oa-oauth", '~> 0.2.0', :require => "omniauth/oauth"
gem "oa-openid", '~> 0.2.0', :require => "omniauth/openid"

gem "rdoc"

group :test do
  gem "webrat", "0.7.2", :require => false
  gem "mocha", :require => false
end

platforms :jruby do
  gem 'activerecord-jdbcsqlite3-adapter'
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
