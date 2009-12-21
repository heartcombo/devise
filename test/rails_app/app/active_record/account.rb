class Account < ActiveRecord::Base
  devise :all

  def self.find_for_authentication(conditions)
    nil
  end
end
