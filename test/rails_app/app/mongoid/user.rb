require 'shared_user'

class User
  include Mongoid::Document
  include Shim
  include SharedUser

  field :username, :type => String
  field :facebook_token, :type => String
end
