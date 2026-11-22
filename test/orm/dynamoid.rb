# frozen_string_literal: true

require "orm/support/dynamodb"

DynamodbTestSupport.configure_dynamoid!
DynamodbTestSupport.drop_tables!

# Create the tables up front: the uniqueness validation queries them before
# Dynamoid's lazy create-on-first-save would kick in.
[User, Admin, UserOnMainApp, UserOnEngine, UserWithValidations, UserWithoutEmail].each do |model|
  model.create_table(sync: true)
  model.include_root_in_json = true
end

class ActiveSupport::TestCase
  setup do
    DynamodbTestSupport.truncate_tables!
  end
end
