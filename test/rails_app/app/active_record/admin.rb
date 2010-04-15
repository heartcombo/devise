class Admin < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :timeoutable, :recoverable
end
