class Admin
  include MongoMapper::Document
  include MongoMapper::Plugins::Callbacks

  devise :authenticatable, :timeoutable, :registerable, :recoverable

  def self.find_for_authentication(conditions)
    last(:conditions => conditions, :order => "email")
  end
end
