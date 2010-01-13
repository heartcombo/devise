class Admin
  include MongoMapper::Document

  devise :authenticatable, :timeoutable

  def self.find_for_authentication(conditions)
    last(:conditions => conditions, :order => "email")
  end
end
