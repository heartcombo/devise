require File.expand_path('../../rails_app/config/environment', __FILE__)
require 'rails/test_help'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new('127.0.0.1', 27017).db("devise-test-suite")
end

I18n.load_path << File.join(
  File.dirname(__FILE__), "mongoid", "locale", "en.yml"
)

class ActiveSupport::TestCase
  setup do
    User.delete_all
    Admin.delete_all
  end
end