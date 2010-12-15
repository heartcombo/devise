require 'rails/generators/active_record'
require 'generators/devise/orm_helpers'

module ActiveRecord
  module Generators
    class DeviseGenerator < ActiveRecord::Generators::Base
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

      include Devise::Generators::OrmHelpers
      source_root File.expand_path("../templates", __FILE__)

      def generate_model
        invoke "active_record:model", [name], :migration => false unless model_exists?
      end

      def copy_devise_migration
        migration_template "migration.rb", "db/migrate/devise_create_#{table_name}"
      end

      def inject_devise_content
        inject_into_class model_path, class_name, model_contents
      end
    end
  end
end
