# frozen_string_literal: true

require 'devise/orm/dynamodb/uniqueness_validator'

module Devise
  module Orm
    module Dynamodb
      # Behaviour shared by the Dynamoid and aws-record integrations. It's
      # included into a model by Devise::Orm when +devise+ is called.
      module Model
        extend ActiveSupport::Concern

        include Devise::Orm::DirtyTrackingDynamodbMethods

        include ActiveModel::ForbiddenAttributesProtection

        module ClassMethods
          # See Devise::Orm::Dynamodb::UniquenessValidator.
          def validates_uniqueness_of(*attr_names)
            validates_with Devise::Orm::Dynamodb::UniquenessValidator, _merge_attributes(attr_names)
          end

          # Atomically increments a numeric attribute in DynamoDB, without
          # loading the record. Used by Lockable to count failed attempts so
          # that concurrent sign in attempts are not lost.
          def increment_counter(counter_name, id, by: 1)
            devise_atomic_increment(counter_name, id, by)
          end

          # Returns every record matching the exact +conditions+ hash. Used by
          # the uniqueness validator. When +case_sensitive+ is false, String
          # values are compared case-insensitively (this always requires a
          # Scan because DynamoDB comparisons are case sensitive).
          def devise_find_all_by(conditions, case_sensitive: true)
            if case_sensitive
              to_adapter.find_all(conditions).to_a
            else
              downcased = conditions.transform_values { |v| v.is_a?(String) ? v.downcase : v }
              to_adapter.find_all.select do |record|
                downcased.all? do |attribute, expected|
                  actual = record.public_send(attribute)
                  actual = actual.downcase if actual.is_a?(String)
                  actual == expected
                end
              end
            end
          end
        end

        # Like ActiveRecord, refuse unpermitted ActionController::Parameters.
        def initialize(attributes = nil, &block)
          super(devise_sanitize_attributes(attributes), &block)
        end

        def assign_attributes(attributes)
          super(devise_sanitize_attributes(attributes))
        end

        # Changes persisted by the last successful save, keyed by attribute
        # name as a String: { "email" => [old, new] }. Inside
        # after_create/after_update/after_save callbacks it returns the
        # changes being persisted by the current save.
        def devise_saved_changes
          (@devise_saving.to_i > 0 ? devise_pending_changes : devise_previous_changes).to_h.stringify_keys
        end

        # Whether +other+ is the same persisted item (same primary key).
        def devise_same_record?(other)
          key = self.class.to_adapter.devise_key_for(self)
          key.present? && key == other.class.to_adapter.devise_key_for(other)
        end

        # ActiveModel::Serialization compares attribute names as Strings, so
        # make sure they're Strings. Otherwise Devise's
        # UNSAFE_ATTRIBUTES_FOR_SERIALIZATION (encrypted_password, tokens, ...)
        # would *not* be removed from +to_json+, +as_json+ and +inspect+.
        def attribute_names_for_serialization
          super.map(&:to_s)
        end

        private

        def devise_sanitize_attributes(attributes)
          attributes = sanitize_for_mass_assignment(attributes || {})
          attributes.respond_to?(:to_unsafe_h) ? attributes.to_h : attributes
        end

        # A counter rather than a boolean so nested saves (e.g. calling
        # `save` from an after_create callback) are handled correctly.
        def devise_track_saving
          @devise_saving = @devise_saving.to_i + 1
          yield
        ensure
          @devise_saving -= 1
        end
      end
    end
  end
end
