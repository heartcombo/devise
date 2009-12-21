require File.join(File.dirname(__FILE__), '..', 'rails_app', 'config', 'environment')
require 'test_help'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define(:version => 1) do
  [:users, :admins, :accounts].each do |table|
    create_table table do |t|
      t.authenticatable :null => table == :admins

      if table != :admin
        t.string :username
        t.confirmable
        t.recoverable
        t.rememberable
        t.trackable
      end

      t.timestamps
    end
  end
end

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end
