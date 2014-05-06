require 'shared_user'

class UserWithoutConfirmation < ActiveRecord::Base
  self.table_name = 'users'
  include Shim

  devise :database_authenticatable, :confirmable, :lockable, :recoverable,
    :registerable, :rememberable, :timeoutable,
    :trackable, :validatable

  def raw_confirmation_token
    @raw_confirmation_token
  end
end
