# frozen_string_literal: true

require 'shared_user_with_two_factor'

class UserWithTwoFactor < ActiveRecord::Base
  self.table_name = 'users'
  include Shim
  include SharedUserWithTwoFactor
end
