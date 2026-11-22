# frozen_string_literal: true

require 'active_model'

module Devise
  module Orm
    module Dynamodb
      # DynamoDB has no secondary unique constraints and neither Dynamoid nor
      # aws-record ship a uniqueness validator, so this validator brings
      # +validates_uniqueness_of+ (used by :validatable) to DynamoDB models.
      #
      # It mirrors the options used by ActiveRecord/Mongoid that are relevant
      # for Devise:
      #
      #   * +:case_sensitive+ - (default: true) when false, compares values
      #     ignoring case. Devise downcases +case_insensitive_keys+ before
      #     validating, so the default works for emails out of the box.
      #   * +:scope+ - one or more attributes that must also match.
      #   * +:conditions+ - a lambda receiving each candidate record, to
      #     filter further.
      #   * plus the standard +:allow_nil+, +:allow_blank+, +:if+, +:unless+,
      #     +:message+ and +:on+ options handled by ActiveModel.
      #
      # The lookup is delegated to the model's +devise_find_all_by+ method,
      # implemented by each DynamoDB integration. It uses a Query against a
      # global secondary index on the attribute when one is declared, and
      # falls back to a full table Scan otherwise.
      #
      # Like every application-level uniqueness check (including the ones in
      # ActiveRecord and Mongoid without a unique index), this check is subject
      # to race conditions between concurrent writes. See the DynamoDB section
      # of the README for details.
      class UniquenessValidator < ActiveModel::EachValidator
        def initialize(options)
          options = { case_sensitive: true }.merge!(options)
          super(options)
        end

        def validate_each(record, attribute, value)
          return if value.nil? && options[:allow_nil]

          conditions = { attribute => value }
          Array(options[:scope]).each do |scope_attribute|
            conditions[scope_attribute] = record.public_send(scope_attribute)
          end

          others = record.class.devise_find_all_by(conditions, case_sensitive: options[:case_sensitive])
          others = others.reject { |other| other.devise_same_record?(record) }

          if (condition = options[:conditions])
            others = others.select { |other| condition.arity.zero? ? other.instance_exec(&condition) : condition.call(other) }
          end

          return if others.empty?

          error_options = options.except(:case_sensitive, :scope, :conditions)
          error_options[:value] = value
          record.errors.add(attribute, :taken, **error_options)
        end
      end
    end
  end
end
