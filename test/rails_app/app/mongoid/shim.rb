module Shim
  extend ::ActiveSupport::Concern

  included do
    include ::Mongoid::Timestamps
    field :created_at, :type => DateTime
  end

  module ClassMethods
    def last(options={})
      options.delete(:order) if options[:order] == "id"
      super(options)
    end

    def find_by_email(email)
      first(:conditions => { :email => email })
    end
  end

  # overwrite equality (because some devise tests use this for asserting model equality)
  def ==(other)
    other.is_a?(self.class) && _id == other._id
  end

  # Mongoid does not have this method in the current beta version (2.0.0.beta.20)
  def update_attribute(attribute, value)
    update_attributes(attribute => value)
  end
end
