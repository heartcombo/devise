class User < ActiveRecord::Base
  devise :database_authenticatable, :confirmable, :lockable, :recoverable,
         :registerable, :rememberable, :timeoutable, :token_authenticatable,
         :trackable, :validatable, :oauthable, :oauth_providers => [:github, :twitter]

  attr_accessible :username, :email, :password, :password_confirmation
end
