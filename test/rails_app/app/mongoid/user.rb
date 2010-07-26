require 'shared_user'

class User
  include Mongoid::Document
  include Shim
  include SharedUser
end
