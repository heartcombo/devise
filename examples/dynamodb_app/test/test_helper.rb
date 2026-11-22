# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Tests talk to DynamoDB (DynamoDB Local by default, see
# config/initializers/dynamodb.rb). Tables are created once and emptied before
# every test.
Rails.application.load_tasks
Rake::Task["devise:dynamodb:create_tables"].invoke

class ActiveSupport::TestCase
  setup do
    User.to_adapter.find_all.each(&:destroy)
    ActionMailer::Base.deliveries.clear
  end
end
