# frozen_string_literal: true

require "aws-record"
require "securerandom"
require "active_model"
require "active_model/serializers/json"
require "orm_adapter/to_adapter"
require "devise/orm/dynamodb/base_adapter"
require "devise/orm/dynamodb/uniqueness_validator"

module Devise
  module Orm
    module Dynamodb
      # aws-record backend. Plugs Devise into Aws::Record models: the
      # class-level primitives BaseAdapter needs, the ActiveRecord-style
      # compatibility methods (callbacks, validations, save/update/destroy,
      # dirty tracking), and the DeviseHook that runs when a model calls +devise+.
      module AwsRecord
        # Time formatter used with +time_attr+. aws-record's default ISO8601
        # formatter drops sub-second precision, which Devise's remember-me
        # comparisons depend on. Stored as an ISO8601 string in UTC with
        # microseconds, which Time.parse reads back losslessly.
        module PreciseTime
          def self.format(time)
            time.getutc.iso8601(6)
          end
        end

        class OrmAdapter < Devise::Orm::Dynamodb::BaseAdapter
        end

        # ActiveModel support that aws-record does not provide. It is mixed
        # into every Aws::Record model when the model includes Aws::Record,
        # so that other concerns (e.g. test models including a Shim) can rely
        # on it being present before +devise+ is called.
        module ActiveModelSupport
          extend ActiveSupport::Concern

          included do
            extend ActiveModel::Naming
            extend ActiveModel::Callbacks
            extend ActiveModel::Translation

            include ActiveModel::Validations
            include ActiveModel::Validations::Callbacks
            include ActiveModel::Conversion
            include ActiveModel::Serializers::JSON

            define_model_callbacks :initialize, :create, :save, :update, :destroy
          end

          class_methods do
            # aws-record copies attributes and keys to a subclass only when the
            # subclass includes Aws::Record itself. Do that automatically so
            # plain Ruby subclasses (STI-style, as with ActiveRecord) work.
            def inherited(subclass)
              super
              subclass.include(::Aws::Record)
            end

            # The topmost Aws::Record class in the hierarchy, as with
            # ActiveRecord's base_class (records of a subclass share its table).
            def base_class
              klass = self
              klass = klass.superclass while klass.superclass.include?(::Aws::Record)
              klass
            end

            private

            # Adds ActiveRecord's attribute query methods (+confirmed_at?+,
            # +active?+), which Devise's views and test app use.
            def _define_attr_methods(name)
              super
              define_method("#{name}?") do
                value = public_send(name)
                value.respond_to?(:zero?) ? !value.zero? : value.present?
              end
            end
          end
        end

        # Prepended to Aws::Record's singleton class so +include Aws::Record+
        # also brings in ActiveModelSupport.
        module IncludeHook
          def included(sub_class)
            super
            sub_class.include(ActiveModelSupport)
          end
        end

        ::Aws::Record.singleton_class.prepend(IncludeHook)

        # Class methods added to every aws-record model that calls +devise+.
        module ModelClassMethods
          # @return [Aws::Record model, nil]
          def dynamodb_find(id)
            return nil if id.nil? || id == ""

            find(keys[:hash] => id)
          end

          # ActiveRecord-style find: raises when the record is missing. Hash
          # arguments keep aws-record's key lookup (used by reload!).
          def find(key)
            return super if key.is_a?(Hash)

            dynamodb_find(key) || raise(dynamodb_record_not_found(key))
          end

          def dynamodb_index?(attribute)
            !dynamodb_index_name_for(attribute).nil?
          end

          def dynamodb_query(attribute, value)
            index_name = dynamodb_index_name_for(attribute)
            attr = attributes.attribute_for(attribute.to_sym)
            query(
              index_name: index_name,
              key_condition_expression: "#k = :v",
              expression_attribute_names: { "#k" => attr.database_name },
              expression_attribute_values: { ":v" => attr.serialize(value) }
            )
          end

          def dynamodb_scan
            scan
          end

          # ActiveRecord-style find_by. Conditions may name the key attribute.
          def find_by(conditions)
            to_adapter.find_first(conditions.dup)
          end

          def create(attributes = {})
            record = new(attributes)
            yield record if block_given?
            record.save
            record
          end

          def create!(attributes = {})
            record = new(attributes)
            yield record if block_given?
            record.save!
            record
          end

          def dynamodb_column_names
            attribute_names.map(&:to_s)
          end

          def dynamodb_record_not_found(id)
            ::Aws::Record::Errors::NotFound.new("Couldn't find #{name} with id=#{id}")
          end

          def dynamodb_table_name
            table_name
          end

          def dynamodb_table_exists?
            table_exists?
          end

          # Creates the table with the model's keys, secondary indexes and an
          # on-demand billing mode. The client settings come from the model's
          # client, so the table is created on the same endpoint.
          def dynamodb_create_table
            klass = self
            config = klass.dynamodb_client.config
            client_options = { endpoint: config.endpoint.to_s, region: config.region, credentials: config.credentials }
            ::Aws::Record::TableConfig.define do |table|
              table.model_class(klass)
              table.client_options(client_options)
              table.billing_mode("PAY_PER_REQUEST")
            end.migrate!
          end

          def dynamodb_drop_table
            dynamodb_client.delete_table(table_name: table_name)
          end

          def dynamodb_truncate_table
            dynamodb_scan.to_a.each(&:delete!)
          end

          # Devise's to_adapter, using the aws-record adapter defined above.
          def to_adapter
            @_to_adapter ||= Devise::Orm::Dynamodb::AwsRecord::OrmAdapter.new(self)
          end

          # Lockable calls +increment_counter(:failed_attempts, id)+. Uses an
          # atomic ADD in an UpdateItem, like ActiveRecord's update_counters.
          def increment_counter(attribute, id)
            hash_key = keys[:hash]
            key_attr = attributes.attribute_for(hash_key)
            counter = attributes.attribute_for(attribute.to_sym)
            dynamodb_client.update_item(
              table_name: table_name,
              key: { key_attr.database_name => key_attr.serialize(id) },
              update_expression: "ADD #c :inc",
              expression_attribute_names: { "#c" => counter.database_name },
              expression_attribute_values: { ":inc" => 1 }
            )
          end

          # ActiveRecord-compatible uniqueness validation.
          def validates_uniqueness_of(*attributes)
            options = attributes.extract_options!
            validates_with Devise::Orm::Dynamodb::UniquenessValidator,
                           _merge_attributes(attributes).merge(options)
          end

          private

          def dynamodb_index_name_for(attribute)
            name, = global_secondary_indexes.find do |_index_name, opts|
              opts[:hash_key] == attribute.to_sym
            end
            name
          end
        end

        # Instance methods added to every model that calls +devise+.
        module CompatMethods
          # aws-record's initializer only accepts declared attributes; assign
          # the rest (virtual attributes such as +password+) through their
          # setters, as ActiveRecord does.
          def initialize(attr_values = {})
            attr_values = (attr_values || {}).to_h
            declared = self.class.attribute_names
            stored, virtual = attr_values.partition { |name, _| declared.include?(name.to_sym) }
            super(stored.to_h)
            virtual.each { |name, value| public_send("#{name}=", value) }
            run_callbacks(:initialize)
          end

          # Devise reads and writes attributes with record[attr]. Like
          # ActiveRecord, only declared attributes are readable this way.
          def [](name)
            public_send(name) if self.class.attribute_names.include?(name.to_sym)
          end

          def []=(name, value)
            public_send("#{name}=", value)
          end

          def save(options = {})
            devise_save(options, raise_on_invalid: false)
          end

          # Raises Aws::Record::Errors::ValidationError when validation fails.
          def save!(options = {})
            devise_save(options, raise_on_invalid: true)
          end

          # ActiveRecord-style update: assigns through the model's setters
          # (so virtual attributes such as +password+ work) and saves.
          def update(attributes = {})
            assign_attributes(attributes)
            save
          end

          def update!(attributes = {})
            assign_attributes(attributes)
            save!
          end

          def reload
            reload!
          end

          def changed?
            dirty?
          end

          # ActiveRecord's update_attribute: saves without validation.
          def update_attribute(name, value)
            public_send("#{name}=", value)
            save(validate: false)
          end

          def destroy
            run_callbacks(:destroy) do
              delete!
              self
            end
          end

          def devise_save_in_progress?
            @devise_save_in_progress == true
          end

          # Dirty tracking API used by Devise::Orm::DirtyTrackingDynamodbMethods.
          # While a save is running, changes are reported from the snapshot
          # taken just before the write; afterwards from the saved changes.

          def attribute_changed?(name)
            pending = devise_pending_changes
            pending ? pending.key?(name.to_sym) : attribute_dirty?(name.to_sym)
          end

          def attribute_was(name)
            pending = devise_pending_changes
            return pending[name.to_sym].first if pending&.key?(name.to_sym)

            super(name.to_sym)
          end

          def attribute_previously_changed?(name)
            (@devise_previous_changes || {}).key?(name.to_sym)
          end

          def attribute_previous_change(name)
            (@devise_previous_changes || {})[name.to_sym]
          end

          def attribute_will_change!(name)
            attribute_dirty!(name.to_sym)
          end

          private

          # Serialize every declared field, like ActiveRecord does with its
          # columns. ActiveModel's :only/:except options are strings.
          def attribute_names_for_serialization
            self.class.attribute_names.map(&:to_s)
          end

          def devise_pending_changes
            @devise_pending_changes if devise_save_in_progress?
          end

          # Runs validations and the save/create-or-update callbacks around
          # the write, in ActiveRecord's order. Returns true or false.
          def devise_save(options, raise_on_invalid:)
            options = options.dup
            validate = options.delete(:validate) { true }
            previous_pending = @devise_pending_changes
            previous_flag = @devise_save_in_progress
            @devise_save_in_progress = true

            if validate && !valid?
              raise ::Aws::Record::Errors::ValidationError, errors.full_messages.join(", ") if raise_on_invalid

              return false
            end

            result = run_callbacks(:save) do
              run_callbacks(new_record? ? :create : :update) { devise_write(options) }
            end
            result ? true : false
          ensure
            @devise_save_in_progress = previous_flag
            @devise_pending_changes = previous_pending
          end

          def devise_write(options)
            devise_assign_key_and_created_at
            self.updated_at = Time.now.utc if dirty? && respond_to?(:updated_at=)
            @devise_pending_changes = devise_changes_snapshot
            if persisted? && !dirty?
              # Nothing to write. Like ActiveRecord, no changes were saved.
              @devise_previous_changes = {}
              return true
            end

            _perform_save(options)
            clean!
            @devise_previous_changes = @devise_pending_changes
            true
          end

          # A new record gets a UUID hash key when it has none (string keys
          # only), and created_at when the model declares it.
          def devise_assign_key_and_created_at
            return unless new_record?

            hash_key = self.class.keys[:hash]
            if hash_key && send(hash_key).nil? && self.class.attributes.attribute_for(hash_key).dynamodb_type == "S"
              send("#{hash_key}=", SecureRandom.uuid)
            end

            return unless respond_to?(:created_at=) && created_at.nil?

            self.created_at = Time.now.utc
          end

          # aws-record serializes "" as a NULL value, which DynamoDB rejects for
          # index keys (and stores as NULL otherwise). Leave blank strings out
          # of the item instead, as Dynamoid does (store_empty_string_as_nil);
          # they read back as the attribute's default.
          def _build_item_for_save
            super.reject { |_name, value| value.nil? }
          end

          def _dirty_changes_for_update
            super.transform_values { |value| value.is_a?(String) && value.empty? ? nil : value }
          end

          def devise_changes_snapshot
            dirty.each_with_object({}) do |name, changes|
              changes[name] = [attribute_was(name), send(name)]
            end
          end
        end

        # Raises if DynamoDB can't be reached. Uses the model's client when a
        # model is given, otherwise a default client.
        def self.ping!(model = nil)
          client = model ? model.dynamodb_client : ::Aws::DynamoDB::Client.new
          client.list_tables(limit: 1)
          true
        end

        # Prepended to Aws::Record::RecordClassMethods (which every Aws::Record
        # model extends). It runs only when a class calls +devise+, the same
        # way the Dynamoid and Mongoid hooks do.
        module DeviseHook
          include Devise::Models

          def devise_modules_hook!
            extend ModelClassMethods
            include CompatMethods
            include Devise::Orm::DirtyTrackingDynamodbMethods
            super
          end
        end
      end
    end
  end
end

::Aws::Record::RecordClassMethods.include Devise::Orm::Dynamodb::AwsRecord::DeviseHook
