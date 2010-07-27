require 'shared_admin'

class Admin
  include Mongoid::Document
  include Shim
  include SharedAdmin
end
