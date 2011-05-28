module Shim
  extend ::ActiveSupport::Concern

  included do
    self.include_root_in_json = true
  end

  # overwrite equality (because some devise tests use this for asserting model equality)
  # def ==(other)
  #   other.is_a?(self.class) && _id == other._id
  # end

  # # Mongoid does not have this method in the current beta version (2.0.0.beta.20)
  # def update_attribute(attribute, value)
  #   update_attributes(attribute => value)
  # end
end
