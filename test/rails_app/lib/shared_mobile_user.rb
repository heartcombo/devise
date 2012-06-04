module SharedMobileUser
  extend ActiveSupport::Concern

  included do
    devise :database_authenticatable, :confirmable, 
           :reconfirmable => true,
           :confirmable_attribute => :phone_number, 
           :unconfirmed_attribute => :unconfirmed_phone_number

    validates_uniqueness_of :phone_number, :if => :phone_number_changed?
  end

end
