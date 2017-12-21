# frozen_string_literal: true

require 'shared_user'

class User < ActiveRecord::Base
  include Shim
  include SharedUser
  include ActiveModel::Serializers::Xml if Devise::Test.rails5?

  validates :sign_in_count, presence: true
end
