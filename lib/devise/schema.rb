module Devise
  # Holds devise schema information. To use it, just include its methods
  # and overwrite the apply_schema method.
  module Schema

    # Creates email, encrypted_password and password_salt.
    #
    # == Options
    # * :null - When true, allow columns to be null.
    # * :encryptor - The encryptor going to be used, necessary for setting the proper encrypter password length.
    # * :skip_email - If you want to use another authentication key, you can skip e-mail creation.
    #                 If you are using an ORM where the devise declaration is in the same class as the schema,
    #                 as in Datamapper or Mongomapper, the email is skipped automatically if not included in
    #                 authentication_keys.
    def authenticatable(options={})
      null = options[:null] || false
      encryptor  = options[:encryptor] || (respond_to?(:encryptor) ? self.encryptor : :sha1)
      have_email = respond_to?(:authentication_keys) ? self.authentication_keys.include?(:email) : true
      skip_email = options[:skip_email] || !have_email

      apply_schema :email,              String, :null => null, :limit => 100 unless skip_email
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

    # Creates sign_in_count, current_sign_in_at, last_sign_in_at,
    # current_sign_in_ip, last_sign_in_in.
    def trackable
      apply_schema :sign_in_count,      Integer
      apply_schema :current_sign_in_at, DateTime
      apply_schema :last_sign_in_at,    DateTime
      apply_schema :current_sign_in_ip, String
      apply_schema :last_sign_in_ip,    String
    end

    # Overwrite with specific modification to create your own schema.
    def apply_schema(name, type, options={})
      raise NotImplementedError
    end
  end
end
