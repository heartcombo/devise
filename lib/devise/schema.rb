module Devise
  # Holds devise schema information. To use it, just include its methods
  # and overwrite the apply_schema method.
  module Schema

    def authenticatable(*args)
      ActiveSupport::Deprecation.warn "t.authenticatable in migrations is deprecated. Please use t.database_authenticatable instead.", caller
      database_authenticatable(*args)
    end

    # Creates email, encrypted_password and password_salt.
    #
    # == Options
    # * :null - When true, allow columns to be null.
    # * :default - Should be set to "" when :null is false.
    def database_authenticatable(options={})
      null    = options[:null] || false
      default = options[:default] || ""

      if options.delete(:encryptor)
        ActiveSupport::Deprecation.warn ":encryptor as option is deprecated, simply remove it."
      end

      apply_schema :email,              String, :null => null, :default => default
      apply_schema :encrypted_password, String, :null => null, :default => default
      apply_schema :password_salt,      String, :null => null, :default => default
    end      

    # Creates authentication_token.
    def token_authenticatable(options={})
      apply_schema :authentication_token, String
    end

    # Creates confirmation_token, confirmed_at and confirmation_sent_at.
    def confirmable
      apply_schema :confirmation_token,   String
      apply_schema :confirmed_at,         DateTime
      apply_schema :confirmation_sent_at, DateTime
    end

    # Creates reset_password_token.
    def recoverable
      apply_schema :reset_password_token, String
    end

    # Creates remember_token and remember_created_at.
    def rememberable
      apply_schema :remember_token,      String
      apply_schema :remember_created_at, DateTime
    end

    # Creates sign_in_count, current_sign_in_at, last_sign_in_at,
    # current_sign_in_ip, last_sign_in_ip.
    def trackable
      apply_schema :sign_in_count,      Integer, :default => 0
      apply_schema :current_sign_in_at, DateTime
      apply_schema :last_sign_in_at,    DateTime
      apply_schema :current_sign_in_ip, String
      apply_schema :last_sign_in_ip,    String
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
        apply_schema :failed_attempts, Integer, :default => 0
      end

      if [:both, :email].include?(unlock_strategy)
        apply_schema :unlock_token, String
      end

      apply_schema :locked_at, DateTime
    end

    # Overwrite with specific modification to create your own schema.
    def apply_schema(name, type, options={})
      raise NotImplementedError
    end
  end
end
