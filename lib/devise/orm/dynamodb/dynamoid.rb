# frozen_string_literal: true

require "dynamoid"
require "orm_adapter/to_adapter"
require "devise/orm/dynamodb/base_adapter"
require "devise/orm/dynamodb/uniqueness_validator"

module Devise
  module Orm
    module Dynamodb
      # Dynamoid backend. Plugs Devise into Dynamoid models: the class-level
      # primitives BaseAdapter needs, the ActiveRecord-style compatibility
      # methods, and the save-in-progress flag used by dirty tracking.
      module Dynamoid
        class OrmAdapter < Devise::Orm::Dynamodb::BaseAdapter
        end

        # Class methods added to every Dynamoid model that calls +devise+.
        module ModelClassMethods
          # @return [Dynamoid model, nil]
          def dynamodb_find(id)
            find(id, raise_error: false)
          end

          def dynamodb_index?(attribute)
            is_global_secondary_index?(attribute)
          end

          def dynamodb_query(attribute, value)
            where(attribute => value).all
          end

          def dynamodb_scan
            all
          end

          # ActiveRecord-style find_by. Dynamoid's find_by is deprecated and
          # cannot condition on the key attribute, so use where(...).first.
          def find_by(conditions)
            where(conditions).first
          end

          def dynamodb_column_names
            attributes.keys.map(&:to_s)
          end

          def dynamodb_record_not_found(id)
            ::Dynamoid::Errors::RecordNotFound.new("Couldn't find #{name} with id=#{id}")
          end

          def dynamodb_table_name
            table_name
          end

          def dynamodb_table_exists?
            ::Dynamoid.adapter.list_tables.include?(table_name)
          end

          def dynamodb_create_table
            create_table(sync: true)
          end

          def dynamodb_drop_table
            delete_table
          end

          def dynamodb_truncate_table
            ::Dynamoid.adapter.truncate(table_name)
          end

          # Devise's to_adapter, using the Dynamoid adapter defined above.
          def to_adapter
            @_to_adapter ||= Devise::Orm::Dynamodb::Dynamoid::OrmAdapter.new(self)
          end

          # Lockable calls +increment_counter(:failed_attempts, id)+; Dynamoid
          # exposes the atomic +inc+ class method.
          def increment_counter(attribute, id)
            inc(id, attribute => 1)
          end

          # ActiveRecord-compatible uniqueness validation.
          def validates_uniqueness_of(*attributes)
            options = attributes.extract_options!
            validates_with Devise::Orm::Dynamodb::UniquenessValidator,
                           _merge_attributes(attributes).merge(options)
          end
        end

        # Instance methods added to every model that calls +devise+.
        module CompatMethods
          # Dynamoid's instance +update+ is the atomic-update API and needs a
          # block. ActiveRecord-style +update(attributes)+ assigns and saves.
          def update(attributes = nil, &block)
            return super(&block) if block || attributes.nil?

            assign_and_save(attributes, validate: true)
          end

          def update!(attributes = nil, &block)
            return super(&block) if block || attributes.nil?

            assign_and_save!(attributes)
          end

          # ActiveRecord applies the pending changes before running after_*
          # callbacks; Dynamoid applies them only once save returns. A save
          # issued from inside a callback (e.g. +after_create :save+) must not
          # see the outer save's changes again (it would rewrite the key and
          # re-run update callbacks), so apply them first, as ActiveRecord does.
          def save(options = {})
            changes_applied if devise_save_in_progress? && persisted?
            super
          end

          def save!(options = {})
            changes_applied if devise_save_in_progress? && persisted?
            super
          end

          def devise_save_in_progress?
            @devise_save_in_progress == true
          end

          private

          # Serialize every declared field, like ActiveRecord does with its
          # columns. Dynamoid's +attributes+ omits fields that were never set,
          # and keys them by symbol while ActiveModel's :only/:except options
          # (and Devise's unsafe-attribute list) are strings.
          def attribute_names_for_serialization
            self.class.attributes.keys.map(&:to_s)
          end

          # Assign through the model's own setters, as ActiveRecord does, so
          # virtual attributes (e.g. +password+) are not written as stored
          # fields. Dynamoid's update_attributes goes through write_attribute.
          def assign_and_save(attributes, validate:)
            attributes.each { |name, value| public_send("#{name}=", value) }
            save(validate: validate)
          end

          def assign_and_save!(attributes)
            attributes.each { |name, value| public_send("#{name}=", value) }
            save!
          end

          # Around-save callback: marks the save window so dirty tracking can
          # report the pending change the way ActiveRecord does in after_update.
          def devise_track_save_in_progress
            previous = @devise_save_in_progress
            @devise_save_in_progress = true
            yield
          ensure
            @devise_save_in_progress = previous
          end
        end

        # Raises if DynamoDB can't be reached.
        def self.ping!
          ::Dynamoid.adapter.list_tables
          true
        end

        # Prepended to Dynamoid::Document::ClassMethods. It runs only when a
        # class calls +devise+, the same way Mongoid's Devise::Models hook does.
        module DeviseHook
          include Devise::Models

          def devise_modules_hook!
            extend ModelClassMethods
            include CompatMethods
            include Devise::Orm::DirtyTrackingDynamodbMethods
            around_save :devise_track_save_in_progress
            super
          end
        end
      end
    end
  end
end

::Dynamoid::Document::ClassMethods.include Devise::Orm::Dynamodb::Dynamoid::DeviseHook
