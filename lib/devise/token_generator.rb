# Deprecate: Copied verbatim from Rails source, remove once we move to Rails 4 only.
require 'thread_safe'
require 'openssl'
require 'securerandom'

module Devise
  class TokenGenerator
    def initialize(key_generator, digest="SHA256")
      @key_generator = key_generator
      @digest = digest
    end

    def digest(klass, column, value)
      if Devise.store_reset_password_tokens_as_raw
        value.present? && value.to_s
      else
        value.present? && OpenSSL::HMAC.hexdigest(@digest, key_for(column), value.to_s)
      end
    end

    def generate(klass, column)
      key = key_for(column)
      if Devise.store_reset_password_tokens_as_raw
        raw = Devise.friendly_token
        enc = raw
        return [raw, enc]
      else
        loop do
          raw = Devise.friendly_token
          enc = OpenSSL::HMAC.hexdigest(@digest, key, raw)
          break [raw, enc] unless klass.to_adapter.find_first({ column => enc })
        end
      end
    end

    private

    def key_for(column)
      @key_generator.generate_key("Devise #{column}")
    end
  end

  # KeyGenerator is a simple wrapper around OpenSSL's implementation of PBKDF2
  # It can be used to derive a number of keys for various purposes from a given secret.
  # This lets Rails applications have a single secure secret, but avoid reusing that
  # key in multiple incompatible contexts.
  class KeyGenerator
    def initialize(secret, options = {})
      @secret = secret
      # The default iterations are higher than required for our key derivation uses
      # on the off chance someone uses this for password storage
      @iterations = options[:iterations] || 2**16
    end

    # Returns a derived key suitable for use.  The default key_size is chosen
    # to be compatible with the default settings of ActiveSupport::MessageVerifier.
    # i.e. OpenSSL::Digest::SHA1#block_length
    def generate_key(salt, key_size=64)
      OpenSSL::PKCS5.pbkdf2_hmac_sha1(@secret, salt, @iterations, key_size)
    end
  end

  # CachingKeyGenerator is a wrapper around KeyGenerator which allows users to avoid
  # re-executing the key generation process when it's called using the same salt and
  # key_size
  class CachingKeyGenerator
    def initialize(key_generator)
      @key_generator = key_generator
      @cache_keys = ThreadSafe::Cache.new
    end

    # Returns a derived key suitable for use.  The default key_size is chosen
    # to be compatible with the default settings of ActiveSupport::MessageVerifier.
    # i.e. OpenSSL::Digest::SHA1#block_length
    def generate_key(salt, key_size=64)
      @cache_keys["#{salt}#{key_size}"] ||= @key_generator.generate_key(salt, key_size)
    end
  end
end
