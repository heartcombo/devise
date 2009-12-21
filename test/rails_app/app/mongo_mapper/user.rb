class User
  include MongoMapper::Document
  key :created_at, DateTime
  devise :all, :timeoutable
  # attr_accessible :username, :email, :password, :password_confirmation
end
