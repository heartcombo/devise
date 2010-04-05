source "http://gemcutter.org"

# Need to install Rails from source
gem "rails", "3.0.0.beta3"
gem "warden", "0.10.3"
gem "sqlite3-ruby", :require => "sqlite3"
gem "webrat", "0.7"
gem "mocha", :require => false
gem "bcrypt-ruby", :require => "bcrypt"

if RUBY_VERSION < '1.9'
  gem "ruby-debug", ">= 0.10.3"
end

group :mongoid do
  gem "mongo",        ">= 0.18.3"
  gem "mongo_ext",    ">= 0.18.3", :require => false
  gem "mongoid", :git => "git://github.com/durran/mongoid.git"
end

group :data_mapper do
  gem "do_sqlite3", '>= 0.10.1'
  gem "dm-core", :git => "git://github.com/datamapper/dm-core.git"
  gem "dm-validations", :git => "git://github.com/datamapper/dm-more.git"
  gem "dm-timestamps", :git => "git://github.com/datamapper/dm-more.git"
  gem "dm-rails", :git => "git://github.com/datamapper/dm-rails.git"
end