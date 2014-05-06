require 'shared_user_without_omniauth'

module RailsEngine
  class User < ActiveRecord::Base
    self.table_name = :users
    include SharedUserWithoutOmniauth
  end
end
