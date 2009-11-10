class DeviseCreate<%= table_name.camelize %> < ActiveRecord::Migration
  def self.up
    create_table(:<%= table_name %>) do |t|
      t.authenticatable :encryptor => :sha1
      t.confirmable
      t.recoverable
      t.rememberable

      t.timestamps
    end

    add_index :<%= table_name %>, :email,                :unique => true
    add_index :<%= table_name %>, :confirmation_token,   :unique => true
    add_index :<%= table_name %>, :reset_password_token, :unique => true
  end

  def self.down
    drop_table :<%= table_name %>
  end
end
