module SharedAdmin
  extend ActiveSupport::Concern

  included do
    devise :database_authenticatable, :registerable, :timeoutable, :recoverable, :lockable, :unlock_strategy => :time
  end
end