require 'shared_user'

class User < ActiveRecord::Base
  include Shim
  include SharedUser

  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :some_number
end
