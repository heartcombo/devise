class User < ActiveRecord::Base
  devise :authenticatable, :confirmable, :recoverable, :rememberable, :trackable,
         :validatable, :timeoutable, :lockable
  attr_accessible :username, :email, :password, :password_confirmation
end
