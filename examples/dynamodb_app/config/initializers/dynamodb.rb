# frozen_string_literal: true

# DynamoDB connection. By default it points to DynamoDB Local
# (docker run -p 8000:8000 amazon/dynamodb-local). Unset DYNAMODB_ENDPOINT and
# configure real AWS credentials (env vars, ~/.aws, or an IAM role) to use AWS.
dynamodb_endpoint = ENV.fetch("DYNAMODB_ENDPOINT", "http://localhost:8000").presence
aws_options = { region: ENV.fetch("AWS_REGION", "us-east-1") }

if dynamodb_endpoint
  aws_options[:endpoint] = dynamodb_endpoint
  # DynamoDB Local accepts any credentials.
  aws_options[:credentials] = Aws::Credentials.new(
    ENV.fetch("AWS_ACCESS_KEY_ID", "local"), ENV.fetch("AWS_SECRET_ACCESS_KEY", "local")
  )
end

# Used by aws-record models.
Aws.config.update(aws_options)

# Used by Dynamoid models.
if defined?(Dynamoid)
  Dynamoid.configure do |config|
    config.namespace = "dynamodb_app_#{Rails.env}"
    config.region = aws_options[:region]
    config.endpoint = aws_options[:endpoint] if aws_options[:endpoint]
    config.credentials = aws_options[:credentials] if aws_options[:credentials]
    config.capacity_mode = :on_demand
  end
end
