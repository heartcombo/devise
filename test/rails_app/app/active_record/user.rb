require 'shared_user'
require 'active_model/serializers/xml' if Devise.rails5?
require 'active_model-serializers' if Devise.rails5?

class User < ActiveRecord::Base
  include Shim
  include SharedUser
  include ActiveModel::Serializers::Xml if Devise.rails5?
end
