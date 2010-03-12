class Admin < ActiveRecord::Base
  devise :authenticatable, :registerable, :timeoutable, :recoverable

  def self.find_for_authentication(conditions)
    last(:conditions => conditions)
  end
end
