# frozen_string_literal: true

# Test-only stand-in for ActiveRecord's `where(...).update_all(...)`: writes
# straight to DynamoDB, skipping validations, callbacks and dirty tracking.
Dynamoid::Criteria::Chain.class_eval do
  def update_all(attributes)
    each { |record| source.update_fields(record.hash_key, attributes) }
  end
end unless Dynamoid::Criteria::Chain.method_defined?(:update_all)

module Shim
  extend ::ActiveSupport::Concern

  module ClassMethods
    def order(attribute)
      to_adapter.find_all(order: attribute)
    end

    def find_by_email(email)
      find_by(email: email)
    end

    def find_by(conditions)
      to_adapter.find_first(conditions)
    end

    def destroy_all
      all.each(&:destroy)
    end
  end
end
