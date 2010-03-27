class User
  include DataMapper::Resource
  
  property :id, Serial
  property :username, String
  
  devise :authenticatable, :http_authenticatable, :confirmable, :lockable, :recoverable,
         :registerable, :rememberable, :timeoutable, :token_authenticatable,
         :trackable

  # :validatable disabled for now
  timestamps :at
  
  def save!(*args)
    save
  end
  
  def self.create!(*args)
    create(*args)
  end
end
