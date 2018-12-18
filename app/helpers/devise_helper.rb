# frozen_string_literal: true

module DeviseHelper
  # Retain this method for backwards compatibility, deprecated in favour of modifying the
  # devise/shared/error_messages partial
  def devise_error_messages!
    return "" if resource.errors.empty?

    render "devise/shared/error_messages", resource: resource
  end
end
