# frozen_string_literal: true

require 'webrat/core/elements/form'
require 'action_dispatch/testing/integration'

module Webrat
  Form.class_eval do
    def self.parse_rails_request_params(params)
      Rack::Utils.parse_nested_query(params)
    end
  end

  module Logging
    # Avoid RAILS_DEFAULT_LOGGER deprecation warning
    def logger # :nodoc:
      ::Rails.logger
    end
  end

  class RailsAdapter
    # This method is private within webrat gem and after Ruby 2.4 we get a lot of warnings because
    # Webrat::Session#response is delegated to this method.
    def response
      integration_session.response
    end

    protected

    def do_request(http_method, url, data, headers)
      update_protocol(url)
      integration_session.send(http_method, normalize_url(url), params: data, headers: headers)
    end
  end
end

module ActionDispatch #:nodoc:
  IntegrationTest.class_eval do
    include Webrat::Methods
    include Webrat::Matchers
  end
end
