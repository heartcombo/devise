require 'rails/generators/active_record'
require 'generators/devise/orm_helpers'


module ActiveRecord
  module Generators
    class DeviseGenerator < ActiveRecord::Generators::Base
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

      include Devise::Generators::OrmHelpers
      source_root File.expand_path("../templates", __FILE__)

      def copy_devise_migration
        exists = model_exists?
        unless behavior == :revoke
          unless exists
            migration_template "migration.rb", "db/migrate/devise_create_#{table_name}"
          else
            migration_template "migration_existing.rb", "db/migrate/add_devise_to_#{table_name}"
          end
        else
          if migration_exists?(table_name)
            migration_template "migration_existing.rb", "db/migrate/add_devise_to_#{table_name}"
          else
            migration_template "migration.rb", "db/migrate/devise_create_#{table_name}"
          end
        end
      end

      def generate_model
        invoke "active_record:model", [name], :migration => false unless model_exists? && behavior == :invoke
      end
      
      def inject_devise_content
        inject_into_class(model_path, class_name, model_contents + <<CONTENT) if model_exists?
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
CONTENT
      end
    end
  end
end
