class Admin < ActiveRecord::Base
  devise :authenticatable, :registerable, :timeoutable, :recoverable
end
