# frozen_string_literal: true

require 'shared_admin'

class Admin
  include Aws::Record
  include Shim
  include SharedAdmin

  configure_client AWS_RECORD_TEST_CLIENT_OPTIONS.dup
  set_table_name "#{AWS_RECORD_TEST_TABLE_PREFIX}admins"

  string_attr :id, hash_key: true

  ## Timestamps (Dynamoid adds these automatically)
  time_attr :created_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime
  time_attr :updated_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime

  ## Database authenticatable
  string_attr :email
  string_attr :encrypted_password

  ## Recoverable
  string_attr :reset_password_token
  time_attr :reset_password_sent_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime

  ## Rememberable
  time_attr :remember_created_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime

  ## Confirmable
  string_attr :confirmation_token
  time_attr :confirmed_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime
  time_attr :confirmation_sent_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime
  string_attr :unconfirmed_email

  ## Lockable
  time_attr :locked_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime

  boolean_attr :active, default_value: false

  global_secondary_index :email_index, hash_key: :email, projection: { projection_type: "ALL" }
  global_secondary_index :unconfirmed_email_index, hash_key: :unconfirmed_email, projection: { projection_type: "ALL" }
  global_secondary_index :reset_password_token_index, hash_key: :reset_password_token, projection: { projection_type: "ALL" }
  global_secondary_index :confirmation_token_index, hash_key: :confirmation_token, projection: { projection_type: "ALL" }
end
