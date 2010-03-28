class Admin
  include DataMapper::Resource  
  
  property :id,   Serial
  property :username, String
  
  devise :authenticatable, :registerable, :timeoutable, :recoverable

  def self.find_for_authentication(conditions)
    last(conditions)
  end
  
  def self.create!(*args)
    create(*args)
  end
  
end
