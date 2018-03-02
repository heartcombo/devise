# frozen_string_literal: true

class DeviseCreate<%= table_name.camelize %> < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :<%= table_name %><%= primary_key_type %> do |t|
<%= migration_data -%>

<% attributes.each do |attribute| -%>
      t.<%= attribute.type %> :<%= attribute.name %>
<% end -%>

      t.timestamps null: false
    end

    add_index :<%= table_name %>, :email,                unique: true
    add_index :<%= table_name %>, :reset_password_token, unique: true, where: '([reset_password_token] IS NOT NULL)'
    # add_index :<%= table_name %>, :confirmation_token,   unique: true, where: '([confirmation_token] IS NOT NULL)'
    # add_index :<%= table_name %>, :unlock_token,         unique: true, where: '([unlock_token] IS NOT NULL)'
  end
end
