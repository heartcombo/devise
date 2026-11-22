# frozen_string_literal: true

module Devise
  module Orm
    module Dynamodb
      # Implementation of the `devise:dynamodb:*` rake tasks.
      module Tasks
        module_function

        # Every model that uses Devise and is stored in DynamoDB.
        def models
          Devise.mappings.values.map(&:to).uniq.select { |model| Devise::Orm.dynamodb?(model) }
        end

        # Creates the table (including its global secondary indexes) of every
        # Devise DynamoDB model that doesn't have one yet. Existing tables are
        # left untouched. Returns { created: [...], existing: [...] }.
        def create_tables(models = self.models, io: $stdout)
          result = { created: [], existing: [] }

          models.uniq { |model| table_name_for(model) }.each do |model|
            table = table_name_for(model)
            if table_exists?(model)
              result[:existing] << table
              io&.puts "#{table} already exists"
            else
              create_table(model)
              result[:created] << table
              io&.puts "#{table} created"
            end
          end

          result
        end

        # Lists the indexes Devise would use and warns about the lookups that
        # fall back to a full table Scan.
        def check_indexes(models = self.models, io: $stdout)
          models.each_with_object({}) do |model, report|
            missing = lookup_attributes(model).reject { |attribute| indexed?(model, attribute) }
            report[model] = missing
            if missing.empty?
              io&.puts "#{model.name}: all Devise lookups use an index"
            else
              io&.puts "#{model.name}: these Devise lookups will Scan the whole table " \
                       "(add a global secondary index to avoid it): #{missing.join(', ')}"
            end
          end
        end

        # Attributes Devise looks records up by, for the modules in +model+.
        def lookup_attributes(model)
          keys = model.authentication_keys
          # Copy: the model's authentication_keys must not be modified.
          attributes = keys.respond_to?(:keys) ? keys.keys : Array(keys).dup
          modules = model.devise_modules
          attributes << :reset_password_token if modules.include?(:recoverable)
          attributes << :confirmation_token if modules.include?(:confirmable)
          attributes << :unconfirmed_email if modules.include?(:confirmable) && model.reconfirmable
          attributes << :unlock_token if modules.include?(:lockable) && [:email, :both].include?(model.unlock_strategy)
          attributes.map(&:to_sym).uniq
        end

        def indexed?(model, attribute)
          if Devise::Orm.dynamoid?(model)
            model.hash_key.to_sym == attribute ||
              model.global_secondary_indexes.values.any? { |index| index.hash_key.to_sym == attribute && index.projected_attributes == :all }
          else
            model.hash_key == attribute ||
              model.global_secondary_indexes.values.any? { |index| index[:hash_key] == attribute && index.dig(:projection, :projection_type).to_s == "ALL" }
          end
        end

        def table_name_for(model)
          model.table_name.to_s
        end

        def table_exists?(model)
          if Devise::Orm.dynamoid?(model)
            ::Dynamoid.adapter.list_tables.include?(table_name_for(model))
          else
            model.table_exists?
          end
        end

        def create_table(model)
          if Devise::Orm.dynamoid?(model)
            model.create_table(sync: true)
          else
            client = model.dynamodb_client
            ::Aws::Record::TableMigration.new(model, client: client).create!(billing_mode: "PAY_PER_REQUEST")
            client.wait_until(:table_exists, table_name: table_name_for(model))
          end
        end
      end
    end
  end
end
