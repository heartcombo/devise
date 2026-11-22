# frozen_string_literal: true

require "test_helper"

if DEVISE_ORM == :dynamodb
  class DynamodbAdapterTest < ActiveSupport::TestCase
    test "to_adapter returns an OrmAdapter for the model" do
      assert_kind_of OrmAdapter::Base, User.to_adapter
      assert_equal User, User.to_adapter.klass
    end

    test "get returns the record for an id" do
      user = create_user
      assert_equal user, User.to_adapter.get(user.id)
    end

    test "get accepts a to_key array" do
      user = create_user
      assert_equal user, User.to_adapter.get(user.to_key)
    end

    test "get returns nil for nil, empty and missing ids" do
      assert_nil User.to_adapter.get(nil)
      assert_nil User.to_adapter.get("")
      assert_nil User.to_adapter.get("does-not-exist")
    end

    test "get! returns the record for an existing id" do
      user = create_user
      assert_equal user, User.to_adapter.get!(user.id)
    end

    test "get! raises for a missing id" do
      assert_raises(StandardError) { User.to_adapter.get!("does-not-exist") }
    end

    test "find_first finds a record by an indexed attribute" do
      user = create_user(email: "indexed@example.com")
      create_user
      assert_equal user, User.to_adapter.find_first(email: "indexed@example.com")
    end

    test "find_first finds a record by a non-indexed attribute" do
      user = create_user(username: "scan_only_name")
      create_user(username: "someone_else")
      assert_equal user, User.to_adapter.find_first(username: "scan_only_name")
    end

    test "find_first returns nil when nothing matches" do
      create_user
      assert_nil User.to_adapter.find_first(email: "nobody@example.com")
      assert_nil User.to_adapter.find_first(username: "nobody")
    end

    test "find_first by id applies extra conditions" do
      user = create_user(username: "with_conditions")
      assert_equal user, User.to_adapter.find_first(id: user.id, username: "with_conditions")
      assert_nil User.to_adapter.find_first(id: user.id, username: "other")
    end

    test "find_first with a nil condition matches records where the attribute is missing" do
      user = create_user
      user.update!(reset_password_token: "token")
      other = create_user
      assert_equal other, User.to_adapter.find_first(reset_password_token: nil, email: other.email)
      assert_nil User.to_adapter.find_first(reset_password_token: nil, id: user.id)
    end

    test "find_all orders ascending and descending" do
      create_user(username: "bravo")
      create_user(username: "alpha")
      create_user(username: "charlie")

      asc = User.to_adapter.find_all(order: [:username, :asc]).map(&:username)
      desc = User.to_adapter.find_all(order: [:username, :desc]).map(&:username)

      assert_equal %w[alpha bravo charlie], asc
      assert_equal %w[charlie bravo alpha], desc
    end

    test "find_all applies limit and offset" do
      create_user(username: "a1")
      create_user(username: "a2")
      create_user(username: "a3")

      assert_equal %w[a1 a2], User.to_adapter.find_all(order: [:username, :asc], limit: 2).map(&:username)
      assert_equal %w[a2 a3], User.to_adapter.find_all(order: [:username, :asc], offset: 1).map(&:username)
    end

    test "find_all with conditions returns only matching records" do
      create_user(username: "same")
      create_user(username: "same")
      create_user(username: "different")

      assert_equal 2, User.to_adapter.find_all(username: "same").size
    end

    test "create! persists a new record" do
      attributes = valid_attributes(email: "adapter_create@example.com")
      user = User.to_adapter.create!(attributes)

      assert user.persisted?
      assert_equal "adapter_create@example.com", User.find(user.id).email
    end

    test "destroy removes the record" do
      user = create_user
      User.to_adapter.destroy(user)

      assert_nil User.to_adapter.get(user.id)
    end

    test "destroy ignores objects of another class" do
      user = create_user
      admin = create_admin

      assert_nil User.to_adapter.destroy(admin)
      assert_equal admin, Admin.to_adapter.get(admin.id)
      assert_equal user, User.to_adapter.get(user.id)
    end

    test "column_names includes the declared fields" do
      columns = User.to_adapter.column_names

      assert_includes columns, "email"
      assert_includes columns, "encrypted_password"
      assert_includes columns, "reset_password_token"
      assert_includes columns, "unconfirmed_email"
    end
  end
end
