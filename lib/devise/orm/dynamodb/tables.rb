# frozen_string_literal: true

module Devise
  module Orm
    module Dynamodb
      # Creates, drops and truncates the DynamoDB tables of Devise models.
      #
      # The per-library work lives in the backend: each backend provides
      # +table_create+, +table_drop+, +table_truncate+, +table_exists?+ and
      # +table_name+ on its model classes (see Dynamoid below).
      module Tables
        class << self
          # Loaded Devise models that are DynamoDB models.
          def models
            mappings = defined?(Devise.mappings) ? Devise.mappings.values : []
            classes = mappings.map(&:to).select { |klass| Devise::Orm.dynamodb?(klass) }
            classes.uniq
          end

          # Creates the table for +model+. Returns the table name.
          # Returns nil when the table already existed (idempotent).
          def create(model)
            return nil if model.dynamodb_table_exists?

            model.dynamodb_create_table
            model.dynamodb_table_name
          end

          # Creates the tables for +models+.
          # @return [Hash] {created: [names], existing: [names]}
          def create_all(models = self.models)
            result = { created: [], existing: [] }
            models.each do |model|
              name = model.dynamodb_table_name
              if model.dynamodb_table_exists?
                result[:existing] << name
              else
                model.dynamodb_create_table
                result[:created] << name
              end
            end
            result
          end

          def drop(model)
            return nil unless model.dynamodb_table_exists?

            model.dynamodb_drop_table
            model.dynamodb_table_name
          end

          def drop_all(models = self.models)
            models.each { |model| drop(model) }
            nil
          end

          def truncate(model)
            model.dynamodb_truncate_table
            model.dynamodb_table_name
          end

          # Raises if DynamoDB can't be reached; returns true otherwise.
          def ping
            if Devise::Orm::Dynamodb.library == :aws_record
              Devise::Orm::Dynamodb::AwsRecord.ping!(models.first)
            else
              Devise::Orm::Dynamodb::Dynamoid.ping!
            end
            true
          end
        end
      end
    end
  end
end
