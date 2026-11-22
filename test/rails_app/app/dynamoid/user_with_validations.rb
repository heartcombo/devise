# frozen_string_literal: true

require "shared_user"

class UserWithValidations
  include Dynamoid::Document
  include Shim
  include SharedUser

  field :username, :string
  field :facebook_token, :string

  ## Database authenticatable
  field :email, :string, default: ""
  field :encrypted_password, :string, default: ""

  # Query emails through an index instead of scanning the table.
  global_secondary_index hash_key: :email, projected_attributes: :all

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
  field :failed_attempts, :integer, default: 0 # Only if lock strategy is :failed_attempts
  field :unlock_token, :string # Only if unlock strategy is :email or :both
  field :locked_at, :datetime

  validates :email, presence: true
end
