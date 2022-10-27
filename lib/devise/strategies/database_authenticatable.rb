# frozen_string_literal: true

require 'devise/strategies/database_password_authenticatable'

module Devise
  module Strategies
    class DatabaseAuthenticatable < DatabasePasswordAuthenticatable
      ActiveSupport::Deprecation.warn <<-DEPRECATION.strip_heredoc
      [Devise] `Devise::Strategies::DatabaseAuthenticatable` is deprecated and will be
      removed in the next major version.
      Use `Devise::Strategies::DatabasePasswordAuthenticatable` instead.
      DEPRECATION
    end
  end
end