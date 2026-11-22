# frozen_string_literal: true

require 'securerandom'
require 'active_model'
require 'devise/orm/dynamodb/model'

module Devise
  module Orm
    module Dynamodb
      # Raised by +save!+/+create!+ on aws-record models when validations fail.
      # Inherits from aws-record's own error so existing rescues keep working.
      class RecordInvalid < ::Aws::Record::Errors::ValidationError
        attr_reader :record

        def initialize(record = nil)
          @record = record
          message = record ? "Validation failed: #{record.errors.full_messages.join(', ')}" : "Validation failed"
          super(message)
        end
      end

      # Model integration for aws-record (https://github.com/aws/aws-sdk-ruby-record).
      #
      # aws-record is intentionally minimal: it has no validations, callbacks
      # or ActiveModel compatibility. This module adds the subset of the
      # ActiveRecord API that Devise (and Rails forms/controllers) rely on:
      #
      #   * ActiveModel validations (+valid?+, +errors+, +validates_*+,
      #     +before_validation+) and +save(validate: false)+.
      #   * +before/after/around+ callbacks for save, create, update and destroy.
      #   * ActiveModel naming, conversion (+to_key+, +to_param+), translation and
      #     JSON serialization.
      #   * An ActiveModel-like dirty API: +changed?+, +changes+, +previous_changes+,
      #     and +<attr>_changed?+, +<attr>_will_change!+, +<attr>_previously_changed?+,
      #     plus ActiveRecord-style +<attr>?+ query methods.
      #   * +create+, +create!+, +find(id)+, +destroy+, +reload+, +update_attribute+,
      #     +[]+ and +[]=+.
      #   * Automatic UUID partition keys for new records with a String partition
      #     key, and +created_at+/+updated_at+ timestamps when those attributes exist.
      #
      # It's included automatically when +devise+ is called. Include it yourself,
      # right after +Aws::Record+, if you want to declare validations or callbacks
      # before calling +devise+:
      #
      #   class User
      #     include Aws::Record
      #     include Devise::Orm::Dynamodb::AwsRecordModel
      #     ...
      #   end
      module AwsRecordModel
        extend ActiveSupport::Concern

        include ActiveModel::Validations
        include ActiveModel::Validations::Callbacks
        include ActiveModel::Conversion
        include ActiveModel::Serializers::JSON
        include Devise::Orm::Dynamodb::Model

        included do
          unless include?(::Aws::Record)
            raise ArgumentError, "#{name} must include Aws::Record before #{Devise::Orm::Dynamodb::AwsRecordModel}"
          end

          extend ActiveModel::Callbacks
          define_model_callbacks :save, :create, :update, :destroy

          attribute_names.each { |name| devise_define_dirty_methods(name) }
        end

        module ClassMethods
          # Like ActiveRecord's +find+: looks up by partition key and raises
          # Devise::Orm::Dynamodb::RecordNotFound if there is no such item.
          # aws-record's own +find(key_hash)+ (returning nil) still works.
          def find(id_or_key)
            return super if id_or_key.is_a?(Hash)

            to_adapter.get!(id_or_key)
          end

          def create(attributes = {})
            new(attributes).tap(&:save)
          end

          def create!(attributes = {})
            new(attributes).tap(&:save!)
          end

          # @private
          def devise_atomic_increment(counter_name, id, by)
            dynamodb_client.update_item(
              table_name: table_name,
              key: { devise_storage_name(hash_key) => attributes.attribute_for(hash_key).serialize(id) },
              update_expression: "ADD #counter :by",
              condition_expression: "attribute_exists(#key)",
              expression_attribute_names: {
                "#counter" => devise_storage_name(counter_name),
                "#key" => devise_storage_name(hash_key)
              },
              expression_attribute_values: { ":by" => by }
            )
            true
          rescue ::Aws::DynamoDB::Errors::ConditionalCheckFailedException
            false
          end

          # @private
          def devise_storage_name(attribute)
            attributes.storage_name_for(attribute.to_sym)
          end

          # aws-record requires every subclass to include Aws::Record again to
          # inherit attributes, keys and indexes. Do it automatically, so
          # subclassing works like it does with ActiveRecord and Mongoid.
          def inherited(subclass)
            super
            subclass.include(::Aws::Record) if subclass.instance_variable_get(:@attributes).nil?
          end

          private

          # Called by aws-record whenever an attribute is declared.
          def _define_attr_methods(name)
            super.tap { devise_define_dirty_methods(name) }
          end

          def devise_define_dirty_methods(name)
            devise_dirty_methods_module.module_eval do
              define_method("#{name}_changed?") { attribute_dirty?(name) }
              define_method("#{name}_will_change!") { attribute_dirty!(name) }
              define_method("#{name}_change") { [attribute_was(name), public_send(name)] if attribute_dirty?(name) }
              define_method("#{name}_previously_changed?") { previous_changes.key?(name.to_s) }
              # ActiveRecord-style query method, e.g. `confirmed_at?`.
              define_method("#{name}?") { public_send(name).present? }
            end
          end

          # Dirty tracking helpers live in their own module (one per class),
          # so methods defined in the model itself take precedence.
          def devise_dirty_methods_module
            if const_defined?(:DeviseDirtyMethods, false)
              const_get(:DeviseDirtyMethods, false)
            else
              Module.new.tap do |mod|
                const_set(:DeviseDirtyMethods, mod)
                include mod
              end
            end
          end
        end

        def valid?(context = nil)
          super(context || (new_record? ? :create : :update))
        end

        # Validates (unless +validate: false+ is given), runs callbacks and
        # persists the record. Returns false if validation fails or a
        # before_* callback halts the chain. Any other option is passed to
        # aws-record (e.g. +force: true+).
        def save(opts = {})
          opts = opts.dup
          validate = opts.delete(:validate) != false
          opts.delete(:touch)
          return false if validate && !valid?

          creating = new_record?
          saved = false

          run_callbacks(:save) do
            run_callbacks(creating ? :create : :update) do
              devise_assign_hash_key if creating
              devise_touch_timestamps(creating)

              changes_to_save = changes
              if creating || dirty?
                super(opts)
              end
              @devise_previously_changed = changes_to_save
              saved = true
            end
          end

          saved
        end

        def save!(opts = {})
          save(opts) || raise(RecordInvalid.new(self))
        end

        # ActiveRecord-like +update(attributes)+. aws-record's +update+ takes
        # an options hash as second argument, which is still supported.
        def update(attributes, opts = {})
          assign_attributes(attributes)
          save(opts)
        end

        def update!(attributes, opts = {})
          assign_attributes(attributes)
          save!(opts)
        end

        # Assigns +value+ and saves without running validations.
        def update_attribute(name, value)
          public_send("#{name}=", value)
          save(validate: false)
        end

        def destroy
          run_callbacks(:destroy) { delete! && true } || false
        end

        # Reloads the attributes with a strongly consistent read.
        def reload
          fresh = self.class.to_adapter.get!(self.class.to_adapter.devise_key_for(self))
          @data = fresh.instance_variable_get(:@data)
          clean!
          self
        end

        # Hash of attribute name (String) to value, like ActiveRecord's.
        def attributes
          attribute_names.each_with_object({}) { |name, hash| hash[name.to_s] = public_send(name) }
        end

        def [](name)
          public_send(name) if self.class.attributes.present?(name.to_sym)
        end

        def []=(name, value)
          public_send("#{name}=", value)
        end

        def changed?
          dirty?
        end

        def changed
          dirty.map(&:to_s)
        end

        def changes
          dirty.each_with_object(ActiveSupport::HashWithIndifferentAccess.new) do |name, hash|
            hash[name] = [attribute_was(name), public_send(name)]
          end
        end

        def previous_changes
          @devise_previously_changed || ActiveSupport::HashWithIndifferentAccess.new
        end

        def devise_saved_changes
          previous_changes.to_h.stringify_keys
        end

        # Records are equal when they are the same persisted item.
        def ==(other)
          super || (other.instance_of?(self.class) && devise_same_record?(other))
        end
        alias_method :eql?, :==

        # Consistent with +eql?+, so records work as Hash keys and with +uniq+.
        def hash
          key = self.class.to_adapter.devise_key_for(self)
          key.present? ? [self.class, key].hash : super
        end

        # +id+ is used by Devise (e.g. Lockable) and by ActiveModel's +to_key+.
        # When the partition key isn't called +id+, +id+ returns its value.
        # (It's not defined as a method so aws-record still lets you declare
        # an +id+ attribute.)
        def method_missing(name, *args, &block)
          if name == :id && args.empty? && devise_id_alias?
            public_send(self.class.hash_key)
          else
            super
          end
        end

        def respond_to_missing?(name, include_private = false)
          (name == :id && devise_id_alias?) || super
        end

        def attribute_names_for_serialization
          self.class.attribute_names.map(&:to_s)
        end

        private

        # Validation already happens in +save+ (honouring +validate: false+).
        def _invalid_record?(_opts)
          false
        end

        # aws-record serializes blank Strings ("") to NULL, which DynamoDB
        # rejects for index keys. Leave those attributes out of new items...
        def _build_item_for_save
          super.reject { |_name, value| value.nil? }
        end

        # ...and send them as nil on updates, so they become a REMOVE.
        def _dirty_changes_for_update
          super.to_h do |name, value|
            serialized = value.nil? ? nil : self.class.attributes.attribute_for(name).serialize(value)
            [name, serialized.nil? ? nil : value]
          end
        end

        def devise_id_alias?
          self.class.hash_key && self.class.hash_key != :id
        end

        def devise_assign_hash_key
          key = self.class.hash_key
          return unless key && public_send(key).blank?
          return unless self.class.attributes.attribute_for(key).dynamodb_type == "S"

          public_send("#{key}=", SecureRandom.uuid)
        end

        def devise_touch_timestamps(creating)
          return unless creating || dirty?

          now = Time.now.utc
          if creating && self.class.attributes.present?(:created_at) && created_at.nil?
            self.created_at = now
          end
          if self.class.attributes.present?(:updated_at) && !attribute_dirty?(:updated_at)
            self.updated_at = now
          end
        end
      end
    end
  end
end
