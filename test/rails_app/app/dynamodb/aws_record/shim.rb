# frozen_string_literal: true

module Shim
  extend ::ActiveSupport::Concern

  included do
    self.include_root_in_json = true
  end

  module ClassMethods
    # aws-record has no count, so scan and count in memory. Tests need an
    # exact count.
    def count
      scan.count
    end

    def destroy_all
      scan.to_a.each(&:destroy)
    end

    def find_by_email(email)
      where(email: email).first
    end

    # Test helper: writes attributes straight to the item, skipping callbacks
    # and validations. Mirrors Dynamoid's update_fields.
    def update_fields(id, attributes)
      record = find(id: id)
      record.assign_attributes(attributes)
      record.send(:_perform_save, {})
      record
    end

    # Minimal where for tests: equality on the given attributes, scanned in
    # memory. Returns a lazy collection that responds to first and each.
    def where(conditions)
      scan.to_a.select do |record|
        conditions.all? { |name, value| record.read_attribute_for_validation(name) == value }
      end
    end
  end

  # overwrite equality (because some devise tests use this for asserting model equality)
  def ==(other)
    other.is_a?(self.class) && id == other.id
  end
end
