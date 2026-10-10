# frozen_string_literal: true

require 'shared_user_with_two_factor'

class UserWithTwoFactor
  include Mongoid::Document
  include Shim
  include SharedUserWithTwoFactor

  field :username, type: String
  field :email, type: String, default: ""
  field :encrypted_password, type: String, default: ""
  field :otp_secret, type: String
end
