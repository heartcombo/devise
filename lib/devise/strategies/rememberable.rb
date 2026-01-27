# frozen_string_literal: true

require 'devise/strategies/password_rememberable'

module Devise
  module Strategies
    class Rememberable < PasswordRememberable
      ActiveSupport::Deprecation.warn <<-DEPRECATION.strip_heredoc
      [Devise] `Devise::Strategies::Rememberable` is deprecated and will be
      removed in the next major version.
      Use `Devise::Strategies::PasswordRememberable` instead.
      DEPRECATION
    end
  end
end