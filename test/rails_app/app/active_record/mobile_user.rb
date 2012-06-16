require 'shared_mobile_user'

class MobileUser < ActiveRecord::Base
  include Shim
  include SharedMobileUser
end
