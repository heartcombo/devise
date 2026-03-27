# frozen_string_literal: true

# Keeping the helper around for backward compatibility.
module DeviseHelper
  def two_factor_method_links(resource, current_method)
    methods = resource.enabled_two_factors - [current_method]
    safe_join(methods.map { |method| render "devise/two_factor/#{method}_link" })
  end
end
