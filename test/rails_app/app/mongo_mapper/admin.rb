require 'shared_admin'

class Admin
  include MongoMapper::Document
  include Shim
  include SharedAdmin

  key :remember_token, String
  timestamps!
end
