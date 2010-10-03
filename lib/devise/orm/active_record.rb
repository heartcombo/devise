module Devise
  module Orm
    # This module contains some helpers and handle schema (migrations):
    #
    #   create_table :accounts do |t|
    #     t.database_authenticatable
    #     t.confirmable
    #     t.recoverable
    #     t.rememberable
    #     t.trackable
    #     t.lockable
    #     t.timestamps
    #   end
    #
    # However this method does not add indexes. If you need them, here is the declaration:
    #
    #   add_index "accounts", ["email"],                :name => "email",                :unique => true
    #   add_index "accounts", ["confirmation_token"],   :name => "confirmation_token",   :unique => true
    #   add_index "accounts", ["reset_password_token"], :name => "reset_password_token", :unique => true
    #
    module ActiveRecord
      module Schema
        include Devise::Schema

        # Tell how to apply schema methods.
        def apply_devise_schema(name, type, options={})
          column name, type.to_s.downcase.to_sym, options
        end
      end

      module Finders
        def devise_find_first_by_identifier(id)
          find(:first, :conditions => { primary_key => Array(id).first})
        end

        def devise_find_first_with_conditions(conditions)
          find(:first, :conditions => conditions)
        end
      end
    end
  end
end

ActiveRecord::Base.extend Devise::Models
ActiveRecord::Base.extend Devise::Orm::ActiveRecord::Finders
ActiveRecord::ConnectionAdapters::Table.send :include, Devise::Orm::ActiveRecord::Schema
ActiveRecord::ConnectionAdapters::TableDefinition.send :include, Devise::Orm::ActiveRecord::Schema
