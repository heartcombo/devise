# frozen_string_literal: true

module Shim
  extend ::ActiveSupport::Concern

  included do
    # Keep each test run isolated from any other table on the endpoint.
    set_table_name "devise_test_#{name.underscore.pluralize}"
  end

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

    # Test-only stand-in for ActiveRecord's `where(...).update_all(...)`:
    # writes straight to DynamoDB, skipping validations and callbacks.
    def where(conditions)
      model = self
      to_adapter.find_all(conditions).tap do |records|
        records.define_singleton_method(:update_all) do |attributes|
          each do |record|
            model.update(attributes.merge(model.hash_key => record.public_send(model.hash_key)))
          end
        end
      end
    end

    def count
      scan.count
    end

    def all
      scan.to_a
    end

    def destroy_all
      all.each(&:destroy)
    end
  end
end
