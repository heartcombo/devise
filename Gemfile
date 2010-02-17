source "http://gemcutter.org"

gem "rails", "3.0.0.beta"
gem "warden", "0.9.3"
gem "sqlite3-ruby", :require => "sqlite3"
gem "webrat", "0.7"
gem "mocha", :require => false
gem "bcrypt-ruby", :require => "bcrypt"

if RUBY_VERSION < '1.9'
  gem "ruby-debug", ">= 0.10.3"
end

group :mongo_mapper do
  gem "mongo",        "0.18.3"
  gem "mongo_ext",    "0.18.3", :require => false
  gem "mongo_mapper", "0.7.0"
end