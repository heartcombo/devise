# frozen_string_literal: true

require 'orm_adapter'

module Devise
  module Orm
    module Dynamodb
      # Raised by +get!+ (and +find(id)+ on aws-record models) when no item
      # exists for the given primary key. Rails responds with a 404, like it
      # does for ActiveRecord::RecordNotFound.
      class RecordNotFound < StandardError; end

      if defined?(::ActionDispatch::ExceptionWrapper)
        ::ActionDispatch::ExceptionWrapper.rescue_responses["Devise::Orm::Dynamodb::RecordNotFound"] = :not_found
      end

      # Base class for the Dynamoid and aws-record OrmAdapter implementations.
      #
      # Devise talks to models exclusively through OrmAdapter, using only
      # equality conditions (e.g. { email: "x" } or { reset_password_token: "y" }).
      # Subclasses implement:
      #
      #   * +get(id)+ - strongly consistent read by partition key.
      #   * +fetch_matching(conditions)+ - returns every item matching the
      #     equality conditions, using a Query when a suitable index exists or
      #     a Scan otherwise.
      #
      # Ordering, limit and offset are applied in memory because DynamoDB
      # can't sort Scan results or skip items. Devise itself never uses them.
      class Adapter < ::OrmAdapter::Base
        # @see OrmAdapter::Base#get!
        def get!(id)
          get(id) || raise(RecordNotFound, "Couldn't find #{klass.name} with #{hash_key}=#{wrap_key(id).inspect}")
        end

        # @see OrmAdapter::Base#find_first
        def find_first(options = {})
          conditions, order = extract_conditions!(options.dup)
          conditions = normalize_conditions(conditions)

          if order.empty?
            if primary_key_lookup?(conditions)
              record = get(conditions[hash_key])
              record if record && matches?(record, conditions)
            else
              fetch_matching(conditions, limit: 1).first
            end
          else
            sort(fetch_matching(conditions), order).first
          end
        end

        # @see OrmAdapter::Base#find_all
        def find_all(options = {})
          conditions, order, limit, offset = extract_conditions!(options.dup)
          conditions = normalize_conditions(conditions)

          records =
            if primary_key_lookup?(conditions)
              Array(find_first(conditions))
            else
              fetch_matching(conditions).to_a
            end

          records = sort(records, order) unless order.empty?
          records = records.drop(offset) if offset
          records = records.first(limit) if limit
          records
        end

        # @see OrmAdapter::Base#create!
        def create!(attributes = {})
          klass.create!(attributes)
        end

        # @see OrmAdapter::Base#destroy
        def destroy(object)
          object.destroy && true if valid_object?(object)
        end

        # The primary key (partition key) value identifying +record+.
        def devise_key_for(record)
          record.public_send(hash_key)
        end

        protected

        # Devise only needs to identify records by their partition key: it's
        # what +to_key+ returns and what is stored in the session.
        def hash_key
          raise NotImplementedError
        end

        def fetch_matching(_conditions, limit: nil)
          raise NotImplementedError
        end

        def valid_object?(object)
          object.is_a?(klass)
        end

        # Symbolizes keys and maps +id+ to the partition key, so that
        # find_first(id: x) works whatever the partition key is called.
        def normalize_conditions(conditions)
          conditions.each_with_object({}) do |(key, value), result|
            key = key.to_sym
            key = hash_key if key == :id && !attribute?(:id)
            result[key] = value
          end
        end

        def primary_key_lookup?(conditions)
          !conditions[hash_key].nil? && !conditions[hash_key].is_a?(Array)
        end

        def matches?(record, conditions)
          conditions.all? { |attribute, value| record.public_send(attribute) == value }
        end

        def sort(records, order)
          records.to_a.sort do |a, b|
            comparison = 0
            order.each do |attribute, direction|
              comparison = compare_values(a.public_send(attribute), b.public_send(attribute))
              comparison = -comparison if direction == :desc
              break unless comparison.zero?
            end
            comparison
          end
        end

        private

        # nil values sort first, like most SQL databases do with ASC.
        def compare_values(x, y)
          return 0 if x.nil? && y.nil?
          return -1 if x.nil?
          return 1 if y.nil?

          (x <=> y) || 0
        end
      end
    end
  end
end
