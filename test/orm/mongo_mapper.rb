require 'mongo_mapper'
MongoMapper.database = "devise-test-suite"
MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017)

require File.join(File.dirname(__FILE__), '..', 'rails_app', 'config', 'environment')
require 'test_help'

module MongoMapper::Document
  # TODO This should not be required
  def invalid?
    !valid?
  end
end

class ActiveSupport::TestCase
  setup do
    User.delete_all
    Admin.delete_all
    Account.delete_all
  end
end