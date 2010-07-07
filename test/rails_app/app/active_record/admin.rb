class Admin < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :timeoutable

  def self.find_for_authentication(conditions)
    last(:conditions => conditions)
  end
end
