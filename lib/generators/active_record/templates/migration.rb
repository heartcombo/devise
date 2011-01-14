class DeviseCreate<%= table_name.camelize %> < ActiveRecord::Migration
  def self.up
    create_table(:<%= table_name %>) do |t|
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable

      # t.encryptable
      # t.confirmable
      # t.lockable :lock_strategy => :<%= Devise.lock_strategy %>, :unlock_strategy => :<%= Devise.unlock_strategy %>
      # t.token_authenticatable

<% for attribute in attributes -%>
      t.<%= attribute.type %> :<%= attribute.name %>
<% end -%>

      t.timestamps
    end

    add_index :<%= table_name %>, :email,                :unique => true
    add_index :<%= table_name %>, :reset_password_token, :unique => true
    # add_index :<%= table_name %>, :confirmation_token,   :unique => true
    # add_index :<%= table_name %>, :unlock_token,         :unique => true
    # add_index :<%= table_name %>, :authentication_token, :unique => true
  end

  def self.down
    drop_table :<%= table_name %>
  end
end
