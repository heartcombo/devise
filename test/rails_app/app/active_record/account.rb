class Account < ActiveRecord::Base
  devise :authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

  def self.find_for_authentication(conditions)
    nil
  end
end
