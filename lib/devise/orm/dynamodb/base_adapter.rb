# frozen_string_literal: true

require "orm_adapter/base"

module Devise
  module Orm
    module Dynamodb
      # Shared OrmAdapter implementation for DynamoDB models. Backend-specific
      # primitives are provided by the model class (the backend extends it):
      #
      #   klass.dynamodb_find(id)              -> record or nil
      #   klass.dynamodb_index?(attribute)     -> true when a GSI exists on it
      #   klass.dynamodb_query(attribute, v)   -> records whose attribute == v
      #   klass.dynamodb_scan                  -> all records (lazy or array)
      #   klass.dynamodb_column_names          -> attribute names
      #   klass.dynamodb_record_not_found(id)  -> exception to raise from get!
      #
      # Ordering, offset and limit are applied in memory.
      class BaseAdapter < OrmAdapter::Base
        def column_names
          klass.dynamodb_column_names
        end

        def get!(id)
          get(id) || raise(klass.dynamodb_record_not_found(wrap_key(id)))
        end

        def get(id)
          key = wrap_key(id)
          return nil if key.nil? || key == ""

          klass.dynamodb_find(key)
        end

        def find_first(options = {})
          find_all(options).first
        end

        def find_all(options = {})
          conditions, order, limit, offset = extract_conditions!(options)
          records = sort_records(fetch(conditions), order)
          records = records.drop(offset) if offset
          records = records.first(limit) if limit
          records
        end

        def create!(attributes = {})
          klass.create!(attributes)
        end

        def destroy(object)
          object.destroy if valid_object?(object)
        end

        protected

        # Returns an array of records matching every condition.
        #
        # An +id+ condition is a direct key lookup. A condition on an attribute
        # with a GSI is a Query on that index; the remaining conditions are
        # filtered in memory. Anything else is a full scan with an in-memory
        # filter.
        def fetch(conditions)
          conditions = conditions.to_h.symbolize_keys

          if conditions.key?(:id)
            id = conditions.delete(:id)
            record = get(id)
            return [] unless record

            return matches?(record, conditions) ? [record] : []
          end

          indexed = conditions.find do |name, value|
            !value.nil? && value != "" && klass.dynamodb_index?(name)
          end

          records = if indexed
                      name, value = indexed
                      klass.dynamodb_query(name, value).to_a.select do |record|
                        matches?(record, conditions.except(name))
                      end
                    else
                      klass.dynamodb_scan.to_a.select { |record| matches?(record, conditions) }
                    end
          records
        end

        # A nil condition matches records where the attribute is missing or nil
        # (ActiveRecord's IS NULL). Other values use equality.
        def matches?(record, conditions)
          conditions.all? do |name, expected|
            actual = record.read_attribute_for_validation(name)
            expected.nil? ? actual.nil? : actual == expected
          end
        end

        def sort_records(records, order)
          return records if order.empty?

          records.sort do |a, b|
            result = 0
            order.each do |name, direction|
              result = compare_values(a.read_attribute_for_validation(name), b.read_attribute_for_validation(name))
              result = -result if direction == :desc
              break unless result.zero?
            end
            result
          end
        end

        # nil sorts first (ascending), matching SQL NULLS FIRST behaviour.
        def compare_values(left, right)
          return 0 if left == right
          return -1 if left.nil?
          return 1 if right.nil?

          left <=> right
        end
      end
    end
  end
end
