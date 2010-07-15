class User < ActiveRecord::Base
  devise :database_authenticatable, :confirmable, :lockable, :recoverable,
         :registerable, :rememberable, :timeoutable, :token_authenticatable,
         :trackable, :validatable, :oauthable, :oauth_providers => [:github, :facebook]

  attr_accessible :username, :email, :password, :password_confirmation

  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    user = ActiveSupport::JSON.decode(access_token.get('/me'))
    create_with_oauth(user)
  end

  def self.create_with_oauth(user, &block)
    User.create(:username => user["username"], :email => user["email"],
      :password => Devise.friendly_token, :confirmed_at => Time.now, &block)
  end
end
