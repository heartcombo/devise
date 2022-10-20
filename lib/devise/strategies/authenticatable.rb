# frozen_string_literal: true

require 'devise/strategies/password_authenticatable'

module Devise
  module Strategies
    class Authenticatable < PasswordAuthenticatable
      ActiveSupport::Deprecation.warn <<-DEPRECATION.strip_heredoc
      [Devise] `Devise::Strategies::Authenticatable` is deprecated and will be
      removed in the next major version.
      Use `Devise::Strategies::PasswordAuthenticatable` instead.
      DEPRECATION
    end
  end
end