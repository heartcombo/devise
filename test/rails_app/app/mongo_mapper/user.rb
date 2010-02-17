class User
  include MongoMapper::Document

  key :created_at, DateTime

  devise :authenticatable, :http_authenticatable, :confirmable, :recoverable,
         :rememberable, :trackable, :validatable, :timeoutable, :lockable,
         :token_authenticatable

  # attr_accessible :username, :email, :password, :password_confirmation
end
