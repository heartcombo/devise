require 'shared_user'

class User < ActiveRecord::Base
  include Shim
  include SharedUser
  include ActiveModel::Serializers::Xml if Devise::Test.rails5?
end
