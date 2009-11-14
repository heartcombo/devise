module Devise
  # Holds devise schema information. To use it, just include its methods
  # and overwrite the apply_schema method.
  module Schema

    # Creates email, encrypted_password and password_salt.
    #
    # == Options
    # * :null when true, allow columns to be null
    # * :encryptor The encryptor going to be used, necessary for setting the proper encrypter password length
    def authenticatable(options={})
      null = options[:null] || false
      encryptor = options[:encryptor] || :sha1

      apply_schema :email,              String, :null => null, :limit => 100
      apply_schema :encrypted_password, String, :null => null, :limit => Devise::ENCRYPTORS_LENGTH[encryptor]
      apply_schema :password_salt,      String, :null => null, :limit => 20
    end

    # Creates confirmation_token, confirmed_at and confirmation_sent_at.
    def confirmable
      apply_schema :confirmation_token,   String, :limit => 20
      apply_schema :confirmed_at,         DateTime
      apply_schema :confirmation_sent_at, DateTime
    end

    # Creates reset_password_token.
    def recoverable
      apply_schema :reset_password_token, String, :limit => 20
    end

    # Creates remember_token and remember_created_at.
    def rememberable
      apply_schema :remember_token,      String, :limit => 20
      apply_schema :remember_created_at, DateTime
    end

    # Overwrite with specific modification to create your own schema.
    def apply_schema(name, tupe, options={})
      raise NotImplementedError
    end
  end
end
