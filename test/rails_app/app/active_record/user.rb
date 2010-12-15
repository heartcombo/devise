require 'shared_user'

class User < ActiveRecord::Base
  include Shim
  include SharedUser
end
