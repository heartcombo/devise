class User
  include Dynamoid::Document

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

  ## Confirmable
  field :confirmation_token, :string
  field :confirmed_at, :datetime
  field :confirmation_sent_at, :datetime
  field :unconfirmed_email, :string # Only if using reconfirmable

  ## Lockable
  field :failed_attempts, :integer, default: 0 # Only if lock strategy is :failed_attempts
  field :unlock_token, :string # Only if unlock strategy is :email or :both
  field :locked_at, :datetime

  ## Global secondary indexes (declared after the fields they use)
  global_secondary_index hash_key: :email, projected_attributes: :all
  global_secondary_index hash_key: :reset_password_token, projected_attributes: :all
  global_secondary_index hash_key: :confirmation_token, projected_attributes: :all # Only if confirmable
  global_secondary_index hash_key: :unconfirmed_email, projected_attributes: :all # Only if using reconfirmable
  global_secondary_index hash_key: :unlock_token, projected_attributes: :all # Only if unlock strategy is :email or :both

  # Enabled Devise modules (V1 set).
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable

end
