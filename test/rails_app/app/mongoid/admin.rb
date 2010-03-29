class Admin
  include Mongoid::Document

  devise :authenticatable, :timeoutable, :registerable, :recoverable
  
  def self.last(options={})
    options.delete(:order) if options[:order] == "id"
    super options
  end
  
  # overwrite equality (because some devise tests use this for asserting model equality) 
  def ==(other)
    other.is_a?(self.class) && _id == other._id
  end
end
