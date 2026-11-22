# frozen_string_literal: true

# User stored in DynamoDB through aws-record.
class User
  include Aws::Record
  include Devise::Orm::Dynamodb::AwsRecordModel

  # Dynamoid and aws-record store some types (e.g. times) differently, so
  # each library gets its own table in this example.
  set_table_name "dynamodb_app_#{Rails.env}_aws_record_users"

  string_attr :id, hash_key: true
  time_attr :created_at
  time_attr :updated_at

  ## Database authenticatable
  string_attr :email
  string_attr :encrypted_password

  ## Recoverable
  string_attr :reset_password_token
  time_attr   :reset_password_sent_at

  ## Rememberable
  time_attr :remember_created_at

  ## Trackable
  integer_attr :sign_in_count, default_value: 0
  time_attr    :current_sign_in_at
  time_attr    :last_sign_in_at
  string_attr  :current_sign_in_ip
  string_attr  :last_sign_in_ip

  ## Confirmable
  string_attr :confirmation_token
  time_attr   :confirmed_at
  time_attr   :confirmation_sent_at
  string_attr :unconfirmed_email

  ## Lockable
  integer_attr :failed_attempts, default_value: 0
  string_attr  :unlock_token
  time_attr    :locked_at

  # Every Devise lookup uses a Query on an index instead of a full Scan
  # (check with `rails devise:dynamodb:check_indexes`).
  %i[email unconfirmed_email reset_password_token confirmation_token unlock_token].each do |attribute|
    global_secondary_index :"#{attribute}_index", hash_key: attribute, projection: { projection_type: "ALL" }
  end

  # The 7 modules supported on DynamoDB.
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :validatable, :confirmable, :trackable, :lockable
end
