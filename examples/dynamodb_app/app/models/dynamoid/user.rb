# frozen_string_literal: true

# User stored in DynamoDB through Dynamoid.
class User
  include Dynamoid::Document

  table name: :users

  ## Database authenticatable
  field :email,              :string, default: ""
  field :encrypted_password, :string, default: ""

  ## Recoverable
  field :reset_password_token,   :string
  field :reset_password_sent_at, :datetime

  ## Rememberable
  field :remember_created_at, :datetime

  ## Trackable
  field :sign_in_count,      :integer, default: 0
  field :current_sign_in_at, :datetime
  field :last_sign_in_at,    :datetime
  field :current_sign_in_ip, :string
  field :last_sign_in_ip,    :string

  ## Confirmable
  field :confirmation_token,   :string
  field :confirmed_at,         :datetime
  field :confirmation_sent_at, :datetime
  field :unconfirmed_email,    :string

  ## Lockable
  field :failed_attempts, :integer, default: 0
  field :unlock_token,    :string
  field :locked_at,       :datetime

  # Every Devise lookup uses a Query on an index instead of a full Scan
  # (check with `rails devise:dynamodb:check_indexes`).
  global_secondary_index hash_key: :email,                projected_attributes: :all
  global_secondary_index hash_key: :unconfirmed_email,    projected_attributes: :all
  global_secondary_index hash_key: :reset_password_token, projected_attributes: :all
  global_secondary_index hash_key: :confirmation_token,   projected_attributes: :all
  global_secondary_index hash_key: :unlock_token,         projected_attributes: :all

  # The 7 modules supported on DynamoDB.
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :validatable, :confirmable, :trackable, :lockable
end
