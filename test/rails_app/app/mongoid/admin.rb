require 'shared_admin'

class Admin
  include Mongoid::Document
  include Shim
  include SharedAdmin

  field :remember_token, :type => String
end
