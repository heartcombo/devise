module SharedAdmin
  extend ActiveSupport::Concern

  included do
    devise :database_authenticatable, :encryptable, :registerable,
           :timeoutable, :recoverable, :lockable,
           :unlock_strategy => :time, :lock_strategy => :none
  end

end
