class User
  include Mongoid::Document
  include Shim

  field :created_at, :type => DateTime

  devise :database_authenticatable, :confirmable, :lockable, :recoverable,
         :registerable, :rememberable, :timeoutable, :token_authenticatable,
         :trackable, :validatable, :oauthable, :oauth_providers => [:github, :facebook]
end
