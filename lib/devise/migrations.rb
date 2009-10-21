module Devise
  # Helpers to migration:
  #
  #   create_table :accounts do |t|
  #     t.authenticable
  #     t.confirmable
  #     t.recoverable
  #     t.rememberable
  #     t.timestamps
  #   end
  #
  # However this method does not add indexes. If you need them, here is the declaration:
  #
  #   add_index "accounts", ["email"],                :name => "email",                :unique => true
  #   add_index "accounts", ["confirmation_token"],   :name => "confirmation_token",   :unique => true
  #   add_index "accounts", ["reset_password_token"], :name => "reset_password_token", :unique => true
  #
  module Migrations

    # Creates email, encrypted_password and password_salt.
    #
    def authenticable
      string :email,              :limit => 100, :null => false
      string :encrypted_password, :limit =>  40, :null => false
      string :password_salt,      :limit =>  20, :null => false
    end

    # Creates confirmation_token, confirmed_at and confirmation_sent_at.
    #
    def confirmable
      string   :confirmation_token, :limit =>  40, :null => true
      datetime :confirmed_at
      datetime :confirmation_sent_at
    end

    # Creates reset_password_token.
    #
    def recoverable
      string :reset_password_token, :limit =>  40, :null => true
    end

    # Creates remember_token and remember_expires_at.
    #
    def rememberable
      string   :remember_token, :limit =>  40, :null => true
      datetime :remember_expires_at
    end

  end
end
