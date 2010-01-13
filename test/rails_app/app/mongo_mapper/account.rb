class Account
  include MongoMapper::Document

  devise :authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

  def self.find_for_authentication(conditions)
    nil
  end
end
