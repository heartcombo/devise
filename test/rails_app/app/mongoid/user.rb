class User
  include Mongoid::Document

  field :created_at, :type => DateTime

  devise :authenticatable, :http_authenticatable, :confirmable, :lockable, :recoverable,
         :registerable, :rememberable, :timeoutable, :token_authenticatable,
         :trackable, :validatable

  # attr_accessible :username, :email, :password, :password_confirmation
  
  def self.last(options={})
    options.delete(:order) if options[:order] == "id"
    super options
  end
end
