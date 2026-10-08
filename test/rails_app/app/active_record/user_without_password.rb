# frozen_string_literal: true

require "shared_user_without_password"

class UserWithoutPassword < ActiveRecord::Base
  self.table_name = 'users'
  include Shim
  include SharedUserWithoutPassword
end
