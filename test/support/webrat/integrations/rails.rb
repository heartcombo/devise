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
end

module ActionDispatch #:nodoc:
  IntegrationTest.class_eval do
    include Webrat::Methods
    include Webrat::Matchers
  end
end
