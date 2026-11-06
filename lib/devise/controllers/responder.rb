# frozen_string_literal: true

module Devise
  module Controllers
    # Custom Responder to configure default statuses that only apply to Devise,
    # and allow to integrate more easily with Hotwire/Turbo.
    class Responder < ActionController::Responder
      self.error_status = :ok
      self.redirect_status = :found
    end
  end
end
