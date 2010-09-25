module SharedAdmin
  extend ActiveSupport::Concern

  included do
    devise :database_authenticatable, :registerable, :timeoutable, :recoverable, :rememberable, :lockable, :unlock_strategy => :time
  end
end