source "http://rubygems.org"

# Need to install Rails from source
gem "rails", "3.0.0.beta4"
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

# group :data_mapper do
#   gem "do_sqlite3", '>= 0.10.1'
#   gem "dm-core", :git => "git://github.com/datamapper/dm-core.git"
#   gem "dm-validations", :git => "git://github.com/datamapper/dm-more.git"
#   gem "dm-timestamps", :git => "git://github.com/datamapper/dm-more.git"
#   gem "dm-rails", :git => "git://github.com/datamapper/dm-rails.git"
# end
