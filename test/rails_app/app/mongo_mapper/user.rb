require 'shared_user'

class User
  include MongoMapper::Document
  include Shim
  include SharedUser

  key :username, String
  key :facebook_token, String
  timestamps!
end
