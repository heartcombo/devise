class Admin < ActiveRecord::Base
  devise :authenticatable, :timeoutable

  def self.find_for_authentication(conditions)
    last(:conditions => conditions)
  end
end
