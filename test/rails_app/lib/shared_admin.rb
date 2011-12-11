module SharedAdmin
  extend ActiveSupport::Concern

  included do
    devise :database_authenticatable, :encryptable, :registerable,
           :timeoutable, :recoverable, :lockable, :confirmable,
           :unlock_strategy => :time, :lock_strategy => :none,
           :confirm_within => 2.weeks, :reconfirmable => true

    validates_uniqueness_of :email, :allow_blank => true, :if => :email_changed?
  end

end
