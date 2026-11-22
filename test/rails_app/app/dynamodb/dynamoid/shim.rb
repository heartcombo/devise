# frozen_string_literal: true

module Shim
  extend ::ActiveSupport::Concern

  included do
    self.include_root_in_json = true
  end

  module ClassMethods
    # Dynamoid's count reads DescribeTable's ItemCount, which DynamoDB only
    # refreshes periodically. Tests need an exact count, so scan.
    def count
      all.count
    end

    def find_by_email(email)
      where(email: email).first
    end
  end

  # overwrite equality (because some devise tests use this for asserting model equality)
  def ==(other)
    other.is_a?(self.class) && id == other.id
  end
end
