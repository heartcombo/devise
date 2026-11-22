# frozen_string_literal: true

# Dynamoid connection settings used by Devise's DynamoDB ORM (see README.md).
#
# Local development talks to DynamoDB Local / dynalite on localhost:8000 by
# default. Point at real AWS by unsetting DYNAMODB_ENDPOINT and providing
# AWS_REGION / AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY.
Dynamoid.configure do |config|
  config.namespace = "devise_dynamodb_example_#{Rails.env}"
  config.region = ENV.fetch("AWS_REGION", "us-east-1")

  endpoint = ENV["DYNAMODB_ENDPOINT"]
  endpoint ||= "http://localhost:8000" if Rails.env.development? || Rails.env.test?
  config.endpoint = endpoint if endpoint

  # Dummy credentials are fine for DynamoDB Local; real AWS needs real keys.
  config.access_key = ENV.fetch("AWS_ACCESS_KEY_ID", "dummy")
  config.secret_key = ENV.fetch("AWS_SECRET_ACCESS_KEY", "dummy")
end
