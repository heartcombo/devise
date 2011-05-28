MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017)
MongoMapper.database = "devise-test-suite"
MongoMapper.database.collections.each { |c| c.drop_indexes }

class ActiveSupport::TestCase
  setup do
    User.collection.remove
    Admin.collection.remove
  end
end
