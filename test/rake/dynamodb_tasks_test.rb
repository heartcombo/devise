# frozen_string_literal: true

require "test_helper"
require "rake"

class DynamodbTasksTest < ActiveSupport::TestCase
  TASKS_FILE = File.expand_path("../../lib/devise/orm/dynamodb/tasks/dynamodb.rake", __dir__)

  class FakeTables
    def self.create_all; end
    def self.drop_all; end
    def self.ping; end
  end

  def setup
    @previous_app = Rake.application
    @app = Rake::Application.new
    Rake.application = @app
    @app.define_task(Rake::Task, :environment)
    load TASKS_FILE

    Rails.application.stubs(:eager_load!)
    @original_force = ENV["FORCE"]
    ENV.delete("FORCE")
    @original_tables = Devise::Orm::Dynamodb::Tables if defined?(Devise::Orm::Dynamodb::Tables)
  end

  def teardown
    Rake.application = @previous_app
    ENV["FORCE"] = @original_force if @original_force
    remove_tables
    Devise::Orm::Dynamodb.const_set(:Tables, @original_tables) if @original_tables
  end

  # Swaps in a fake Tables. The real constant (present when the suite runs with
  # DEVISE_ORM=dynamodb) is restored in teardown.
  def define_tables(tables)
    Devise::Orm.const_set(:Dynamodb, Module.new) unless defined?(Devise::Orm::Dynamodb)
    remove_tables
    Devise::Orm::Dynamodb.const_set(:Tables, tables)
  end

  def remove_tables
    Devise::Orm::Dynamodb.send(:remove_const, :Tables) if defined?(Devise::Orm::Dynamodb::Tables)
  end

  def run_task(name)
    capture_io { @app[name].invoke }
  end

  def stub_env(name)
    Rails.stubs(:env).returns(ActiveSupport::EnvironmentInquirer.new(name))
  end

  test "create_tables prints created and existing tables sorted" do
    tables = FakeTables
    define_tables(tables)
    tables.expects(:create_all).returns(created: ["users", "admins"], existing: ["monsters"])

    out, = run_task("devise:dynamodb:create_tables")
    assert_equal "admins created\nusers created\nmonsters already exists\n", out
  end

  test "drop_tables refuses in production without FORCE" do
    tables = FakeTables
    define_tables(tables)
    stub_env("production")
    tables.expects(:drop_all).never

    error = assert_raises(SystemExit) { run_task("devise:dynamodb:drop_tables") }
    assert_equal 1, error.status
  end

  test "drop_tables runs in production with FORCE=true" do
    tables = FakeTables
    define_tables(tables)
    stub_env("production")
    ENV["FORCE"] = "true"
    tables.expects(:drop_all).once

    out, = run_task("devise:dynamodb:drop_tables")
    assert_equal "DynamoDB tables dropped\n", out
  end

  test "drop_tables drops tables outside production" do
    tables = FakeTables
    define_tables(tables)
    stub_env("test")
    tables.expects(:drop_all).once

    out, = run_task("devise:dynamodb:drop_tables")
    assert_equal "DynamoDB tables dropped\n", out
  end

  test "ping reports a reachable endpoint" do
    define_tables(FakeTables)
    FakeTables.expects(:ping).once

    out, = run_task("devise:dynamodb:ping")
    assert_equal "DynamoDB is reachable\n", out
  end

  test "ping aborts when the endpoint cannot be reached" do
    define_tables(FakeTables)
    FakeTables.expects(:ping).raises(StandardError, "connection refused")

    error = assert_raises(SystemExit) { run_task("devise:dynamodb:ping") }
    assert_equal 1, error.status
  end

  test "tasks abort with a helpful message when the DynamoDB ORM is not loaded" do
    remove_tables
    error = assert_raises(SystemExit) { run_task("devise:dynamodb:create_tables") }
    assert_equal 1, error.status
  end
end
