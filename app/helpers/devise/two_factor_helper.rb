# frozen_string_literal: true

module Devise
  module TwoFactorHelper
    # Renders the link partials provided by each registered 2FA extension,
    # excluding the method currently being challenged. Each extension is
    # expected to ship a `devise/two_factor/<method>_link` partial.
    def two_factor_method_links(resource, current_method)
      methods = resource.enabled_two_factors - [current_method]
      safe_join(methods.map { |method| render "devise/two_factor/#{method}_link" })
    end
  end
end
