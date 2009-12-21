class Account
  include MongoMapper::Document

  devise :all

  def self.find_for_authentication(conditions)
    nil
  end
end
