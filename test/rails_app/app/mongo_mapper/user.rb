class User
  include MongoMapper::Document
  key :created_at, DateTime
  devise :all, :timeoutable, :lockable
  # attr_accessible :username, :email, :password, :password_confirmation
end
