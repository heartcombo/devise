module Shim
  extend ::ActiveSupport::Concern

  included do
    include ::ActiveModel::MassAssignmentSecurity
    include ::Mongoid::Timestamps
    field :created_at, :type => DateTime
  end

  module ClassMethods
    def last(options = {})
      options.delete(:order) if options[:order] == "id"
      where(options).last
    end

    def find_by_email(email)
      find_by(:email => email)
    end
  end

  # overwrite equality (because some devise tests use this for asserting model equality)
  def ==(other)
    other.is_a?(self.class) && _id == other._id
  end
end
