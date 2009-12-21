class Admin < ActiveRecord::Base
  devise :all, :timeoutable, :except => [:recoverable, :confirmable, :rememberable, :validatable, :trackable]

  def self.find_for_authentication(conditions)
    last(:conditions => conditions)
  end
end
