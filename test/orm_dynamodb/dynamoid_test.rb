# frozen_string_literal: true

require "test_helper"

# Dynamoid-specific behaviour: these tests reach into the Dynamoid adapter
# and config, so they only run with DEVISE_DYNAMODB_LIBRARY=dynamoid.
if DEVISE_ORM == :dynamodb && DEVISE_DYNAMODB_LIBRARY == :dynamoid
  class DynamoidBackendTest < ActiveSupport::TestCase
    test "ping raises when the endpoint is unreachable" do
      adapter = Dynamoid.instance_variable_get(:@adapter)
      original_endpoint = Dynamoid::Config.endpoint
      begin
        Dynamoid::Config.endpoint = "http://localhost:1"
        Dynamoid.instance_variable_set(:@adapter, nil)
        assert_raises(StandardError) { Devise::Orm::Dynamodb::Tables.ping }
      ensure
        Dynamoid::Config.endpoint = original_endpoint
        Dynamoid.instance_variable_set(:@adapter, adapter)
      end
    end
  end
end
