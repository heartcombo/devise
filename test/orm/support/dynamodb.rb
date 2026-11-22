# frozen_string_literal: true

require "aws-sdk-dynamodb"

# Helpers shared by test/orm/dynamoid.rb and test/orm/aws_record.rb.
#
# The tests need a DynamoDB compatible endpoint. Set DYNAMODB_ENDPOINT
# (default: http://localhost:8000), e.g. by running DynamoDB Local:
#
#   docker run -p 8000:8000 amazon/dynamodb-local
module DynamodbTestSupport
  ENDPOINT = ENV.fetch("DYNAMODB_ENDPOINT", "http://localhost:8000")
  REGION = ENV.fetch("AWS_REGION", "us-east-1")
  NAMESPACE = "devise_test"

  module_function

  def client_options
    {
      endpoint: ENDPOINT,
      region: REGION,
      credentials: Aws::Credentials.new("fake", "fake")
    }
  end

  def client
    @client ||= Aws::DynamoDB::Client.new(client_options)
  end

  def configure_dynamoid!
    Dynamoid.configure do |config|
      config.endpoint = ENDPOINT
      config.region = REGION
      config.access_key = "fake"
      config.secret_key = "fake"
      config.namespace = NAMESPACE
      config.warn_on_scan = false
      config.logger = nil
      # Tables are created lazily on the first save of each model.
      config.create_table_on_save = true
      config.read_capacity = 5
      config.write_capacity = 5
    end
  end

  def configure_aws_record!
    # aws-record builds its clients from the global AWS SDK configuration.
    Aws.config.update(client_options)
  end

  def create_aws_record_table(model)
    Aws::Record::TableMigration.new(model, client: client).create!(billing_mode: "PAY_PER_REQUEST")
    client.wait_until(:table_exists, table_name: model.table_name)
  end

  # Drops the test tables left by a previous run, so they're recreated with
  # the current schema (e.g. new indexes) when first used.
  def drop_tables!
    test_tables.each { |table| client.delete_table(table_name: table) }
  end

  def test_tables
    client.list_tables.table_names.select { |table| table.start_with?(NAMESPACE) }
  end

  # Deletes every item of every devise test table, keeping the tables.
  def truncate_tables!
    test_tables.each do |table|
      key_names = client.describe_table(table_name: table).table.key_schema.map(&:attribute_name)
      client.scan(table_name: table, projection_expression: key_names.map.with_index { |_, i| "#k#{i}" }.join(", "),
                  expression_attribute_names: key_names.each_with_index.to_h { |k, i| ["#k#{i}", k] }).each_page do |page|
        page.items.each_slice(25) do |items|
          requests = items.map { |item| { delete_request: { key: item } } }
          client.batch_write_item(request_items: { table => requests })
        end
      end
    end
  end
end
