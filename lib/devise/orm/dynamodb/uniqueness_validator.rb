# frozen_string_literal: true

module Devise
  module Orm
    module Dynamodb
      # Mirrors ActiveRecord's UniquenessValidator for DynamoDB models.
      #
      # Supported options: :case_sensitive (default true), :scope (attribute
      # name or array), plus the standard :allow_nil, :allow_blank, :if,
      # :unless, :on and :message. The error symbol is :taken.
      class UniquenessValidator < ActiveModel::EachValidator
        RESERVED_OPTIONS = %i[case_sensitive scope allow_nil allow_blank if unless on].freeze

        def validate_each(record, attribute, value)
          return unless taken?(record, attribute, value)

          record.errors.add(attribute, :taken, **error_options(value))
        end

        private

        def taken?(record, attribute, value)
          scope_values = Array(options[:scope]).to_h do |scope_attribute|
            [scope_attribute.to_sym, record.read_attribute_for_validation(scope_attribute)]
          end

          candidates(record.class, attribute, value, scope_values).any? do |other|
            !same_record?(record, other)
          end
        end

        # Returns the stored records whose +attribute+ matches +value+ (and the
        # scope values). Equality goes through the adapter, which uses a GSI
        # when one exists and otherwise scans. Case-insensitive comparisons are
        # done in memory. DynamoDB rejects EQ on NULL, so nil values are matched
        # in memory too.
        def candidates(klass, attribute, value, scope_values)
          if options.fetch(:case_sensitive, true) && !value.nil? && value != ""
            klass.to_adapter.find_all({ attribute.to_sym => value }.merge(scope_values))
          else
            # Scan all records and compare in memory; DynamoDB has no
            # case-insensitive index.
            needle = value.to_s.downcase
            klass.dynamodb_scan.to_a.select do |other|
              stored = other.read_attribute_for_validation(attribute)
              stored.is_a?(String) && stored.downcase == needle &&
                scope_values.all? { |name, expected| other.read_attribute_for_validation(name) == expected }
            end
          end
        end

        def same_record?(record, other)
          record.persisted? && base_class(other.class) == base_class(record.class) && other.id == record.id
        end

        def base_class(klass)
          klass.respond_to?(:base_class) ? klass.base_class : klass
        end

        def error_options(value)
          options.except(*RESERVED_OPTIONS).merge(value: value)
        end
      end
    end
  end
end
