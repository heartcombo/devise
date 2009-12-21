class User < ActiveRecord::Base
  devise :all, :timeoutable
  attr_accessible :username, :email, :password, :password_confirmation
end
