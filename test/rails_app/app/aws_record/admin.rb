# frozen_string_literal: true

require 'shared_admin'

class Admin
  include Aws::Record
  include Devise::Orm::Dynamodb::AwsRecordModel
  include Shim

  string_attr :id, hash_key: true
  time_attr :created_at
  time_attr :updated_at
  include SharedAdmin

  ## Database authenticatable
  string_attr :email
  string_attr :encrypted_password

  ## Recoverable
  string_attr :reset_password_token
  time_attr :reset_password_sent_at

  ## Rememberable
  time_attr :remember_created_at

  ## Confirmable
  string_attr :confirmation_token
  time_attr :confirmed_at
  time_attr :confirmation_sent_at
  string_attr :unconfirmed_email # Only if using reconfirmable

  ## Lockable
  time_attr :locked_at

  boolean_attr :active, default_value: false

  # Query emails through an index instead of scanning the table.
  global_secondary_index :email_index, hash_key: :email, projection: { projection_type: "ALL" }
end
