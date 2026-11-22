# frozen_string_literal: true

require 'devise/orm/dynamodb/adapter'

module Devise
  module Orm
    module Dynamodb
      # OrmAdapter for Dynamoid models. Registered as
      # +Dynamoid::Document::OrmAdapter+ so +Model.to_adapter+ finds it.
      class DynamoidAdapter < Adapter
        # @see OrmAdapter::Base#column_names
        def column_names
          klass.attributes.keys.map(&:to_s)
        end

        # @see OrmAdapter::Base#get
        def get(id)
          id = wrap_key(id)
          return if id.blank?

          klass.find(id, raise_error: false, consistent_read: true)
        end

        protected

        def hash_key
          klass.hash_key.to_sym
        end

        def attribute?(name)
          klass.attributes.key?(name.to_sym)
        end

        # Dynamoid picks a Query on a global secondary index automatically
        # when the conditions include its hash key with an equality operator
        # (and the index projects all attributes). Otherwise it Scans.
        def fetch_matching(conditions, limit: nil)
          chain = klass.where(dynamoid_conditions(conditions))
          chain = chain.consistent unless uses_index?(conditions)
          chain = chain.record_limit(limit) if limit
          chain.to_a
        end

        private

        # DynamoDB doesn't store nil values, so `attr = nil` becomes an
        # "attribute does not exist" check.
        def dynamoid_conditions(conditions)
          conditions.each_with_object({}) do |(attribute, value), result|
            if value.nil?
              result[:"#{attribute}.null"] = true
            else
              result[attribute] = value
            end
          end
        end

        # Strongly consistent reads aren't supported on global secondary
        # indexes, only on the table itself.
        def uses_index?(conditions)
          klass.global_secondary_indexes.values.any? do |index|
            !conditions[index.hash_key].nil? && index.projected_attributes == :all
          end
        end
      end
    end
  end
end
