class User < ActiveRecord::Base
  devise :all
  attr_accessible :username, :email, :password, :password_confirmation
end
