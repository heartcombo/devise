require File.expand_path('../../rails_app/config/environment', __FILE__)
require 'rails/test_help'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)

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
        t.lockable
        t.token_authenticatable
      end

      t.timestamps
    end
  end
end

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end
