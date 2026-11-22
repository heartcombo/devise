# frozen_string_literal: true

require 'devise/orm/dynamodb/adapter'

module Devise
  module Orm
    module Dynamodb
      # OrmAdapter for aws-record models. Registered as
      # +Aws::Record::OrmAdapter+ so +Model.to_adapter+ finds it.
      class AwsRecordAdapter < Adapter
        # @see OrmAdapter::Base#column_names
        def column_names
          klass.attribute_names.map(&:to_s)
        end

        # @see OrmAdapter::Base#get
        def get(id)
          id = wrap_key(id)
          return if id.blank?

          klass.find_with_opts(key: { hash_key => id }, consistent_read: true)
        end

        protected

        def hash_key
          klass.hash_key.to_sym
        end

        def attribute?(name)
          klass.attributes.present?(name.to_sym)
        end

        # Uses a Query on the first global secondary index whose hash key is
        # part of the conditions (and that projects all attributes), filtering
        # the remaining conditions. Falls back to a consistent Scan.
        def fetch_matching(conditions, limit: nil)
          index_name, index = matching_index(conditions)
          names = {}
          values = {}

          filters = conditions.each_with_index.filter_map do |(attribute, value), i|
            next if index && attribute == index[:hash_key]

            names["#f#{i}"] = klass.devise_storage_name(attribute)
            if value.nil?
              "attribute_not_exists(#f#{i})"
            else
              values[":f#{i}"] = serialize(attribute, value)
              "#f#{i} = :f#{i}"
            end
          end

          params = {}
          if index
            names["#k"] = klass.devise_storage_name(index[:hash_key])
            values[":k"] = serialize(index[:hash_key], conditions[index[:hash_key]])
            params[:index_name] = index_name.to_s
            params[:key_condition_expression] = "#k = :k"
          else
            params[:consistent_read] = true
          end
          params[:filter_expression] = filters.join(" AND ") if filters.any?
          params[:expression_attribute_names] = names if names.any?
          params[:expression_attribute_values] = values if values.any?

          collection = index ? klass.query(params) : klass.scan(params)
          limit ? collection.first(limit) : collection.to_a
        end

        private

        def matching_index(conditions)
          klass.global_secondary_indexes.find do |_name, index|
            !conditions[index[:hash_key]].nil? &&
              index.dig(:projection, :projection_type).to_s == "ALL"
          end
        end

        def serialize(attribute, value)
          klass.attributes.attribute_for(attribute).serialize(value)
        end
      end
    end
  end
end
