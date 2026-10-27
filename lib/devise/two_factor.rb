# frozen_string_literal: true

module Devise
  module TwoFactor
    autoload :PendingSignIn, "devise/two_factor/pending_sign_in"
    autoload :UrlHelpers,    "devise/two_factor/url_helpers"
  end
end
