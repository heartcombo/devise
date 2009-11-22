module Devise
  module Orm
    # This module contains some helpers and handle schema (migrations):
    #
    #   create_table :accounts do |t|
    #     t.authenticatable
    #     t.confirmable
    #     t.recoverable
    #     t.rememberable
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
      # Required ORM hook. Just yield the given block in ActiveRecord.
      def self.included_modules_hook(klass, modules)
        yield
      end

      include Devise::Schema

      # Tell how to apply schema methods.
      def apply_schema(name, type, options={})
        column name, type.to_s.downcase.to_sym, options
      end
    end
  end
end

if defined?(ActiveRecord)
  ActiveRecord::Base.extend Devise::Models
  ActiveRecord::ConnectionAdapters::TableDefinition.send :include, Devise::Orm::ActiveRecord
end
