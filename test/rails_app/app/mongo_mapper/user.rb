class User
  include MongoMapper::Document
  key :created_at, DateTime
  devise :authenticatable, :http_authenticatable, :confirmable, :lockable, :recoverable,
         :registerable, :rememberable, :timeoutable, :token_authenticatable,
         :trackable, :validatable
  # attr_accessible :username, :email, :password, :password_confirmation

  def self.last(options={})
    options.merge!(:order => 'email')
    super options
  end

end
