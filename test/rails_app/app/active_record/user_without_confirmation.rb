require 'shared_user_without_omniauth'

class UserWithoutConfirmation < ActiveRecord::Base
  self.table_name = 'users'
  include Shim
  include SharedUserWithoutOmniauth
end
