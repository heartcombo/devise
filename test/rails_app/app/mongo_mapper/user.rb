class User
  include MongoMapper::Document
  devise :all, :timeoutable
  # attr_accessible :username, :email, :password, :password_confirmation
end
