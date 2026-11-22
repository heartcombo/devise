# frozen_string_literal: true

# Devise's DynamoDB ORM test setup. The library defaults to Dynamoid and is
# chosen with DEVISE_DYNAMODB_LIBRARY. The emulator endpoint defaults to
# dynalite on localhost:8000 (override with DYNAMODB_ENDPOINT).
DEVISE_DYNAMODB_LIBRARY = (ENV["DEVISE_DYNAMODB_LIBRARY"] || :dynamoid).to_sym

Devise.dynamodb_library = DEVISE_DYNAMODB_LIBRARY

if DEVISE_DYNAMODB_LIBRARY == :aws_record
  require "aws-record"

  # Each aws-record model builds its own client from these options (see
  # test/rails_app/app/dynamodb/aws_record/*.rb, which call configure_client
  # and set_table_name with the prefix below).
  AWS_RECORD_TEST_CLIENT_OPTIONS = {
    endpoint: ENV["DYNAMODB_ENDPOINT"] || "http://localhost:8000",
    credentials: Aws::Credentials.new("devise-test", "devise-test"),
    region: "us-east-1"
  }.freeze
  # Distinct from Dynamoid's "devise_test_" namespace: both libraries would
  # otherwise share table names, and each stores times in a different format.
  AWS_RECORD_TEST_TABLE_PREFIX = "devise_aws_test_"
else
  require "dynamoid"

  Dynamoid.configure do |config|
    config.endpoint = ENV["DYNAMODB_ENDPOINT"] || "http://localhost:8000"
    config.credentials = Aws::Credentials.new("devise-test", "devise-test")
    config.region = "us-east-1"
    config.namespace = "devise_test"
    config.warn_on_scan = false
    config.logger = nil
  end
end

class ActiveSupport::TestCase
  setup do
    Devise::Orm::Dynamodb::Tables.create_all
    Devise::Orm::Dynamodb::Tables.models.each do |model|
      Devise::Orm::Dynamodb::Tables.truncate(model)
    end
  end
end
