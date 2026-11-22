# frozen_string_literal: true

require "test_helper"

if DEVISE_ORM == :dynamodb
  class DynamodbUniquenessValidatorTest < ActiveSupport::TestCase
    setup do
      @validator_class = Devise::Orm::Dynamodb::UniquenessValidator
    end

    # Runs the validator directly against +record+ and returns the errors on +attribute+.
    def errors_for(record, attribute = :email, **options)
      record.errors.clear
      @validator_class.new(attributes: [attribute], **options).validate(record)
      record.errors[attribute]
    end

    test "duplicate email is reported as :taken with the AR message" do
      user = create_user(email: "dup@example.com")
      other = new_user(email: "dup@example.com")

      assert_equal ["has already been taken"], errors_for(other)
      assert_equal user.email, other.email
    end

    test "the error uses the :taken symbol" do
      create_user(email: "symbol@example.com")
      other = new_user(email: "symbol@example.com")
      errors_for(other)

      assert other.errors.of_kind?(:email, :taken)
    end

    test "a persisted record does not conflict with itself" do
      user = create_user(email: "self@example.com")

      assert_empty errors_for(user)
    end

    test "a different record with the same email conflicts even when it is persisted" do
      create_user(email: "first@example.com")
      second = create_user(email: "second@example.com")
      second.email = "first@example.com"

      assert_equal ["has already been taken"], errors_for(second)
    end

    test "no conflict when no other record has the value" do
      create_user(email: "other@example.com")

      assert_empty errors_for(new_user(email: "unique@example.com"))
    end

    test "case_sensitive true distinguishes case" do
      create_user(email: "case@example.com")
      record = new_user(email: "CASE@example.com")

      assert_empty errors_for(record, case_sensitive: true)
    end

    test "case_sensitive false ignores case" do
      create_user(email: "case@example.com")
      record = new_user(email: "CASE@example.com")

      assert_equal ["has already been taken"], errors_for(record, case_sensitive: false)
    end

    test "case_sensitive defaults to true" do
      create_user(email: "default@example.com")

      assert_empty errors_for(new_user(email: "DEFAULT@example.com"))
    end

    test "allow_blank skips blank values" do
      stored = User.new(valid_attributes(email: ""))
      stored.save(validate: false)
      record = new_user(email: "")

      assert_empty errors_for(record, allow_blank: true)
      assert_equal ["has already been taken"], errors_for(record)
    end

    test "allow_nil skips nil values" do
      record = new_user
      record.email = nil

      assert_empty errors_for(record, allow_nil: true)
    end

    test "scope limits the uniqueness check to matching scope values" do
      create_user(email: "scoped@example.com", username: "alice")

      same_scope = new_user(email: "scoped@example.com", username: "alice")
      other_scope = new_user(email: "scoped@example.com", username: "bob")

      assert_equal ["has already been taken"], errors_for(same_scope, scope: :username)
      assert_empty errors_for(other_scope, scope: :username)
    end

    test "custom message replaces the default" do
      create_user(email: "message@example.com")
      record = new_user(email: "message@example.com")

      assert_equal ["is already in use"], errors_for(record, message: "is already in use")
    end

    test "non-reserved options are passed to the error" do
      create_user(email: "option@example.com")
      record = new_user(email: "option@example.com")
      errors_for(record, message: "taken already", extra: "x")

      assert_equal "option@example.com", record.errors.details[:email].first[:value]
      assert_equal "x", record.errors.details[:email].first[:extra]
    end

    test "validatable uses the same rule: a second user with the same email is invalid" do
      create_user(email: "validatable@example.com")
      second = new_user(email: "validatable@example.com")

      refute second.valid?
      assert_equal ["has already been taken"], second.errors[:email]
    end

    test "validatable: an email differing only by case is a duplicate because Devise downcases keys" do
      create_user(email: "mixed@example.com")
      second = new_user(email: "MIXED@example.com")

      refute second.valid?
      assert_equal ["has already been taken"], second.errors[:email]
    end

    test "validatable: a record that is re-saved with its own email is valid" do
      user = create_user(email: "resave@example.com")

      assert user.valid?
    end

    test "validatable: a unique email is valid" do
      assert new_user(email: "fresh-#{SecureRandom.hex(4)}@example.com").valid?
    end
  end
end
