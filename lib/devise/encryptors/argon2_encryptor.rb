# frozen_string_literal: true

require 'argon2'

module Devise
  module Encryptors
    module Argon2Encryptor extend self
      def digest(klass, password)
        hasher = Argon2::Password.new(m_cost:, p_cost:, secret:, t_cost:)
        hasher.create(password)
      end

      def compare(klass, hashed_password, password)
        return false if hashed_password.blank?

        if secret
          Argon2::Password.verify_password(
            "#{password}#{klass.pepper}",
            hashed_password,
            secret
          )
        else
          Argon2::Password.verify_password(
            "#{password}#{klass.pepper}",
            hashed_password
          )
        end
      end

      private

      def m_cost
        @__m_cost__ ||= Devise.argon2_m_cost
      end

      def p_cost
        @__p_cost__ ||= 1
      end

      def secret
        @__secret__ ||= Devise.secret_key
      end

      def t_cost
        @__t_cost__ ||= 2
      end
    end
  end
end
end
end
