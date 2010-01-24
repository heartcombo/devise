class User < ActiveRecord::Base
  devise :authenticatable, :confirmable, :recoverable, :rememberable, :trackable,
         :validatable, :timeoutable, :lockable, :token_authenticatable
  attr_accessible :username, :email, :password, :password_confirmation
end
