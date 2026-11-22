# frozen_string_literal: true

require 'shared_admin'

class Admin
  include Dynamoid::Document
  include Shim
  include SharedAdmin

  table name: :admins, key: :id

  ## Database authenticatable
  field :email, :string
  field :encrypted_password, :string

  ## Recoverable
  field :reset_password_token, :string
  field :reset_password_sent_at, :datetime

  ## Rememberable
  field :remember_created_at, :datetime

  ## Confirmable
  field :confirmation_token, :string
  field :confirmed_at, :datetime
  field :confirmation_sent_at, :datetime
  field :unconfirmed_email, :string

  ## Lockable
  field :locked_at, :datetime

  field :active, :boolean, default: false

  global_secondary_index hash_key: :email, projected_attributes: :all
  global_secondary_index hash_key: :unconfirmed_email, projected_attributes: :all
  global_secondary_index hash_key: :reset_password_token, projected_attributes: :all
  global_secondary_index hash_key: :confirmation_token, projected_attributes: :all
end
