module Devise
  # Helpers to migration:
  #
  #   create_table :accounts do |t|
  #     t.authenticatable
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
    # == Options
    # * :null when true, allow columns to be null
    # * :encryptor The encryptor going to be used, necessary for setting the proper encrypter password length
    #
    def authenticatable(options={})
      null = options[:null] || false
      encryptor = options[:encryptor] || :sha1

      string :email,              :null => null, :limit => 100
      string :encrypted_password, :null => null, :limit => Devise::ENCRYPTORS_LENGTH[encryptor]
      string :password_salt,      :null => null, :limit => 20
    end

    # Creates confirmation_token, confirmed_at and confirmation_sent_at.
    #
    def confirmable
      string   :confirmation_token, :limit => 20
      datetime :confirmed_at
      datetime :confirmation_sent_at
    end

    # Creates reset_password_token.
    #
    def recoverable
      string :reset_password_token, :limit => 20
    end

    # Creates remember_token and remember_created_at.
    #
    def rememberable
      string   :remember_token, :limit => 20
      datetime :remember_created_at
    end

  end
end
