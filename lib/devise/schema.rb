module Devise
  # Holds devise schema information. To use it, just include its methods
  # and overwrite the apply_schema method.
  module Schema

    # Creates email when enabled (on by default), encrypted_password and password_salt.
    #
    # == Options
    # * :null - When true, allow columns to be null.
    # * :default - Should be set to "" when :null is false.
    #
    # == Notes
    # For Datamapper compatibility, we explicitly hardcode the limit for the
    # encrypter password field in 128 characters.
    def database_authenticatable(options={})
      null    = options[:null] || false
      default = options.key?(:default) ? options[:default] : ("" if null == false)
      include_email = !respond_to?(:authentication_keys) || self.authentication_keys.include?(:email)

      apply_devise_schema :email,              String, :null => null, :default => default if include_email
      apply_devise_schema :encrypted_password, String, :null => null, :default => default, :limit => 128
    end

    # Creates password salt for encryption support.
    def encryptable
      apply_devise_schema :password_salt, String
    end

    # Creates authentication_token.
    def token_authenticatable
      apply_devise_schema :authentication_token, String
    end

    # Creates confirmation_token, confirmed_at and confirmation_sent_at.
    def confirmable
      apply_devise_schema :confirmation_token,   String
      apply_devise_schema :confirmed_at,         DateTime
      apply_devise_schema :confirmation_sent_at, DateTime
    end

    # Creates reset_password_token and reset_password_sent_at.
    #
    # == Options
    # * :reset_within - When true, adds a column that reset passwords within some date
    def recoverable(options={})
      use_within = options.fetch(:reset_within, Devise.reset_password_within.present?)
      apply_devise_schema :reset_password_token, String
      apply_devise_schema :reset_password_sent_at, DateTime if use_within
    end

    # Creates remember_token and remember_created_at.
    #
    # == Options
    # * :use_salt - When true, does not create a remember_token and use password_salt instead.
    def rememberable(options={})
      use_salt = options.fetch(:use_salt, Devise.use_salt_as_remember_token)
      apply_devise_schema :remember_token,      String unless use_salt
      apply_devise_schema :remember_created_at, DateTime
    end

    # Creates sign_in_count, current_sign_in_at, last_sign_in_at,
    # current_sign_in_ip, last_sign_in_ip.
    def trackable
      apply_devise_schema :sign_in_count,      Integer, :default => 0
      apply_devise_schema :current_sign_in_at, DateTime
      apply_devise_schema :last_sign_in_at,    DateTime
      apply_devise_schema :current_sign_in_ip, String
      apply_devise_schema :last_sign_in_ip,    String
    end

    # Creates failed_attempts, unlock_token and locked_at depending on the options given.
    #
    # == Options
    # * :unlock_strategy - The strategy used for unlock. Can be :time, :email, :both (default), :none.
    #   If :email or :both, creates a unlock_token field.
    # * :lock_strategy - The strategy used for locking. Can be :failed_attempts (default) or :none.
    def lockable(options={})
      unlock_strategy   = options[:unlock_strategy]
      unlock_strategy ||= self.unlock_strategy if respond_to?(:unlock_strategy)
      unlock_strategy ||= :both

      lock_strategy   = options[:lock_strategy]
      lock_strategy ||= self.lock_strategy if respond_to?(:lock_strategy)
      lock_strategy ||= :failed_attempts

      if lock_strategy == :failed_attempts
        apply_devise_schema :failed_attempts, Integer, :default => 0
      end

      if [:both, :email].include?(unlock_strategy)
        apply_devise_schema :unlock_token, String
      end

      apply_devise_schema :locked_at, DateTime
    end

    # allows the account to be disabled by setting the disabled? flag.
    def disableable
      apply_devise_schema :disabled, :boolean
    end

    # Overwrite with specific modification to create your own schema.
    def apply_devise_schema(name, type, options={})
      raise NotImplementedError
    end
  end
end
