Mongoid.configure do |config|
  config.master = Mongo::Connection.new('127.0.0.1', 27017).db("devise-test-suite")
end

class ActiveSupport::TestCase
  setup do
    User.delete_all
    Admin.delete_all
  end
end