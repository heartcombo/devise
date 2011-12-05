require 'orm_adapter/adapters/active_record'

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
          @__devise_warning_raised ||= begin
            ActiveSupport::Deprecation.warn "You are using t.database_authenticatable and others in your migration " \
              "and this feature is deprecated. Please simply use Rails helpers instead as mentioned here: " \
              "https://github.com/plataformatec/devise/wiki/How-To:-Upgrade-to-Devise-2.0-migration-schema-style"
            true
          end
          column name, type.to_s.downcase.to_sym, options
        end
      end
    end
  end
end

ActiveRecord::Base.extend Devise::Models
ActiveRecord::ConnectionAdapters::Table.send :include, Devise::Orm::ActiveRecord::Schema
ActiveRecord::ConnectionAdapters::TableDefinition.send :include, Devise::Orm::ActiveRecord::Schema