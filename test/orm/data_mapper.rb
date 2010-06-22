require 'rails/test_help'

DataMapper.auto_migrate!

class ActiveSupport::TestCase
  setup do
    User.all.destroy!
    Admin.all.destroy!
  end
end
