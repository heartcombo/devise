# frozen_string_literal: true

class AddOtpSecretToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :otp_secret, :string
  end
end
