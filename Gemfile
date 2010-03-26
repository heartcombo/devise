source "http://gemcutter.org"

# Need to install Rails from source
gem "rails", :git => "git://github.com/rails/rails.git"
gem "warden", "0.10.2"
gem "sqlite3-ruby", :require => "sqlite3"
gem "webrat", "0.7"
gem "mocha", :require => false
gem "bcrypt-ruby", :require => "bcrypt"

if RUBY_VERSION < '1.9'
  gem "ruby-debug", ">= 0.10.3"
end

group :mongo_mapper do
  gem "mongo",        ">= 0.18.3"
  gem "mongo_ext",    ">= 0.18.3", :require => false
  gem "mongo_mapper", :git => "git://github.com/jnunemaker/mongomapper.git"
end
