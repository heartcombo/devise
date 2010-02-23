class Admin
  include MongoMapper::Document
  devise :authenticatable, :registerable, :timeoutable

  def self.find_for_authentication(conditions)
    last(:conditions => conditions)
  end

  def self.last(options={})
    options.merge!(:order => 'email')
    super options
  end
end
