# frozen_string_literal: true

require 'shared_user_without_omniauth'

class UserOnMainApp
  include Aws::Record
  include Shim
  include SharedUserWithoutOmniauth

  configure_client AWS_RECORD_TEST_CLIENT_OPTIONS.dup
  set_table_name "#{AWS_RECORD_TEST_TABLE_PREFIX}user_on_main_apps"

  string_attr :id, hash_key: true

  ## Timestamps (Dynamoid adds these automatically)
  time_attr :created_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime
  time_attr :updated_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime

  string_attr :username
  string_attr :facebook_token

  ## Database authenticatable
  string_attr :email, default_value: ""
  string_attr :encrypted_password

  ## Recoverable
  string_attr :reset_password_token
  time_attr :reset_password_sent_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime

  ## Rememberable
  time_attr :remember_created_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime

  ## Trackable
  integer_attr :sign_in_count, default_value: 0
  time_attr :current_sign_in_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime
  time_attr :last_sign_in_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime
  string_attr :current_sign_in_ip
  string_attr :last_sign_in_ip

  ## Confirmable
  string_attr :confirmation_token
  time_attr :confirmed_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime
  time_attr :confirmation_sent_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime

  ## Lockable
  integer_attr :failed_attempts, default_value: 0
  string_attr :unlock_token
  time_attr :locked_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime
  global_secondary_index :email_index, hash_key: :email, projection: { projection_type: "ALL" }
  global_secondary_index :reset_password_token_index, hash_key: :reset_password_token, projection: { projection_type: "ALL" }
  global_secondary_index :confirmation_token_index, hash_key: :confirmation_token, projection: { projection_type: "ALL" }
  global_secondary_index :unlock_token_index, hash_key: :unlock_token, projection: { projection_type: "ALL" }
end
