require 'shared_user'

class User < ActiveRecord::Base
  include Shim
  include SharedUser

  attr_accessible :username, :email, :first_name, :last_name, :password, :password_confirmation, :remember_me

  skip_authentification_for :first_name, :last_name
end
