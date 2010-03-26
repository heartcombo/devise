class Admin
  include Mongoid::Document

  devise :authenticatable, :timeoutable, :registerable, :recoverable

  def self.find_for_authentication(conditions)
    last(:conditions => conditions, :sort => [[:email, :asc]])
  end
  
  def self.last(options={})
    options.delete(:order) if options[:order] == "id"
    super options
  end
end
