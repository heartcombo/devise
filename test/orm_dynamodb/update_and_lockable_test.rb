# frozen_string_literal: true

require "test_helper"

if DEVISE_ORM == :dynamodb
  class DynamodbUpdateAndLockableTest < ActiveSupport::TestCase
    test "update with attributes persists and returns true" do
      user = create_user(username: "before")

      assert user.update(username: "after")
      assert_equal "after", User.find(user.id).username
    end

    test "update returns false and sets errors for invalid attributes" do
      create_user(email: "taken-update@example.com")
      user = create_user

      refute user.update(email: "taken-update@example.com")
      assert_equal ["has already been taken"], user.errors[:email]
      assert_not_equal "taken-update@example.com", User.find(user.id).email
    end

    test "update! raises for invalid attributes" do
      create_user(email: "taken-update-bang@example.com")
      user = create_user

      assert_raises(StandardError) do
        user.update!(email: "taken-update-bang@example.com")
      end
      assert_not_equal "taken-update-bang@example.com", User.find(user.id).email
    end

    test "update! persists valid attributes" do
      user = create_user(username: "bang_before")
      user.update!(username: "bang_after")

      assert_equal "bang_after", User.find(user.id).username
    end

    test "failed attempts are incremented atomically in the database" do
      user = create_user
      copy_a = User.find(user.id)
      copy_b = User.find(user.id)

      copy_a.send(:increment_failed_attempts)
      copy_b.send(:increment_failed_attempts)

      assert_equal 2, User.find(user.id).failed_attempts
    end

    test "increment_counter increments the stored counter by one" do
      user = create_user

      User.increment_counter(:failed_attempts, user.id)

      assert_equal 1, User.find(user.id).failed_attempts
    end
  end
end
