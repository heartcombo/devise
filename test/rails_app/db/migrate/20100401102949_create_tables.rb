class CreateTables < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username
      t.string :facebook_token

      t.database_authenticatable :null => false
      t.confirmable
      t.recoverable
      t.rememberable
      t.trackable
      t.lockable
      t.token_authenticatable
      t.timestamps
    end

    create_table :admins do |t|
      t.database_authenticatable :null => true, :encryptor => :bcrypt
      t.recoverable
      t.lockable
      t.timestamps
    end
  end

  def self.down
    drop_table :users
    drop_table :admins
  end
end
