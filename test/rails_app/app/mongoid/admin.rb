require 'shared_admin'

class Admin
  include Mongoid::Document
  include Shim
  include SharedAdmin

  ## Database authenticatable
  field :email,              :type => String, :null => true
  field :encrypted_password, :type => String, :null => true

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Encryptable
  field :password_salt, :type => String

  ## Lockable
  field :locked_at, :type => Time
end
