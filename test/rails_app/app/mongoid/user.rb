class User
  include Mongoid::Document

  field :created_at, :type => DateTime

  devise :database_authenticatable, :confirmable, :lockable, :recoverable,
         :registerable, :rememberable, :timeoutable, :token_authenticatable,
         :trackable, :validatable

  # attr_accessible :username, :email, :password, :password_confirmation
  
  def self.last(options={})
    options.delete(:order) if options[:order] == "id"
    super options
  end
  
  # overwrite equality (because some devise tests use this for asserting model equality) 
  def ==(other)
    other.is_a?(self.class) && _id == other._id
  end
end
