module RailsEngine
  class User < ActiveRecord::Base
    self.table_name = :users

    devise :database_authenticatable, :confirmable, :lockable, :recoverable,
      :registerable, :rememberable, :timeoutable,
      :trackable, :validatable
  end
end
