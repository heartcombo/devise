# frozen_string_literal: true

require "shared_user"

class UserWithValidations
  include Aws::Record
  include Devise::Orm::Dynamodb::AwsRecordModel
  include Shim

  string_attr :id, hash_key: true
  time_attr :created_at
  time_attr :updated_at
  include SharedUser

  string_attr :username
  string_attr :facebook_token

  ## Database authenticatable
  string_attr :email
  string_attr :encrypted_password

  ## Recoverable
  string_attr :reset_password_token
  time_attr :reset_password_sent_at

  ## Rememberable
  time_attr :remember_created_at

  ## Trackable
  integer_attr :sign_in_count, default_value: 0
  time_attr :current_sign_in_at
  time_attr :last_sign_in_at
  string_attr :current_sign_in_ip
  string_attr :last_sign_in_ip

  ## Lockable
  integer_attr :failed_attempts, default_value: 0 # Only if lock strategy is :failed_attempts
  string_attr :unlock_token # Only if unlock strategy is :email or :both
  time_attr :locked_at

  validates :email, presence: true

  # Like `default: ""` in ActiveRecord: applied once, on initialization.
  # (aws-record's `default_value` would make nil impossible to store.)
  def initialize(attributes = {})
    super
    self.email = "" if email.nil?
    self.encrypted_password = "" if encrypted_password.nil?
  end

  # Query emails through an index instead of scanning the table.
  global_secondary_index :email_index, hash_key: :email, projection: { projection_type: "ALL" }
end
