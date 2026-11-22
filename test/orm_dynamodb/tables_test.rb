# frozen_string_literal: true

require "test_helper"

if DEVISE_ORM == :dynamodb
  class DynamodbTablesTest < ActiveSupport::TestCase
    setup do
      @tables = Devise::Orm::Dynamodb::Tables
    end

    test "models lists the DynamoDB Devise models from Devise.mappings" do
      models = @tables.models

      assert_includes models, User
      assert_includes models, Admin
      assert models.all? { |model| Devise::Orm.dynamodb?(model) }
      assert_equal models.uniq, models
    end

    test "ping returns true when DynamoDB is reachable" do
      assert_equal true, @tables.ping
    end

    test "create_all is idempotent and reports existing tables" do
      first = @tables.create_all([User])
      second = @tables.create_all([User])

      assert_equal({ created: [], existing: [User.dynamodb_table_name] }, second)
      assert_kind_of Hash, first
      assert_equal [User.dynamodb_table_name], (first[:created] + first[:existing])
    end

    test "drop and drop_all remove tables, and create recreates them" do
      assert_equal User.dynamodb_table_name, @tables.drop(User)
      assert_not User.dynamodb_table_exists?
      assert_nil @tables.drop(User), "dropping a missing table should be a no-op"

      assert_equal User.dynamodb_table_name, @tables.create(User)
      assert_nil @tables.create(User), "creating an existing table should be a no-op"

      @tables.drop_all([User, Admin])
      assert_not User.dynamodb_table_exists?
      assert_not Admin.dynamodb_table_exists?
    ensure
      @tables.create_all
    end

    test "truncate removes all items from the table" do
      create_user
      create_user
      assert_operator User.count, :>=, 2

      @tables.truncate(User)

      assert_equal 0, User.count
    end
  end
end
