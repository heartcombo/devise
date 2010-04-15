class CreateTables < ActiveRecord::Migration
  def self.up
    [:users, :admins, :accounts].each do |table|
      create_table table do |t|
        t.database_authenticatable :null => (table == :admins)

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

  def self.down
    [:users, :admins, :accounts].each do |table|
      drop_table table
    end
  end
end
