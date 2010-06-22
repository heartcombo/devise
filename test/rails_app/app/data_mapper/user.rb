class User
  include DataMapper::Resource

  extend  Devise::Orm::DataMapper::Schema
  include Devise::Orm::DataMapper::Compatibility

  property :id, Serial
  property :username, String
  
  devise :database_authenticatable, :confirmable, :lockable, :recoverable,
         :registerable, :rememberable, :timeoutable, :token_authenticatable,
         :trackable, :validatable

  timestamps :at
  
  def self.create!(*args)
    create(*args)
  end
  
  def self.destroy_all
    all.destroy
  end
end
