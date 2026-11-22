# frozen_string_literal: true

require "shared_user"

class UserWithValidations
  include Dynamoid::Document
  include Shim
  include SharedUser

  table name: :user_with_validations, key: :id

  field :username, :string
  field :facebook_token, :string

  ## Database authenticatable
  field :email, :string, default: ""
  field :encrypted_password, :string, default: ""

  ## Recoverable
  field :reset_password_token, :string
  field :reset_password_sent_at, :datetime

  ## Rememberable
  field :remember_created_at, :datetime

  ## Trackable
  field :sign_in_count, :integer, default: 0
  field :current_sign_in_at, :datetime
  field :last_sign_in_at, :datetime
  field :current_sign_in_ip, :string
  field :last_sign_in_ip, :string

  ## Lockable
  field :failed_attempts, :integer, default: 0
  field :unlock_token, :string
  field :locked_at, :datetime

  global_secondary_index hash_key: :email, projected_attributes: :all
  global_secondary_index hash_key: :reset_password_token, projected_attributes: :all
  global_secondary_index hash_key: :unlock_token, projected_attributes: :all

  validates :email, presence: true
end
