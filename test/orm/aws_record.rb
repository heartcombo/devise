# frozen_string_literal: true

require "orm/support/dynamodb"

DynamodbTestSupport.configure_aws_record!
DynamodbTestSupport.drop_tables!

[User, Admin, UserOnMainApp, UserOnEngine, UserWithValidations, UserWithoutEmail].each do |model|
  DynamodbTestSupport.create_aws_record_table(model)
  model.include_root_in_json = true
end

class ActiveSupport::TestCase
  setup do
    DynamodbTestSupport.truncate_tables!
  end
end
