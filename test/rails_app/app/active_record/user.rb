class User < ActiveRecord::Base
  devise :all, :timeoutable, :lockable
  attr_accessible :username, :email, :password, :password_confirmation
end
