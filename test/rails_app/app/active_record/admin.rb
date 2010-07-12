class Admin < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :timeoutable, :recoverable, :lockable, :unlock_strategy => :time
end
