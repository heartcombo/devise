# frozen_string_literal: true

require "test_helper"

if DEVISE_ORM == :dynamodb
  class DynamodbLibrarySelectionTest < ActiveSupport::TestCase
    test "Devise.dynamodb_library defaults to dynamoid" do
      # The test app overrides the value, so check a fresh process.
      lib = File.expand_path("../../lib", __dir__)
      output = IO.popen([RbConfig.ruby, "-I", lib, "-e", 'require "devise"; print Devise.dynamodb_library.inspect'], &:read)
      assert_equal ":dynamoid", output
    end

    test "the test suite uses the library chosen with DEVISE_DYNAMODB_LIBRARY" do
      assert_equal DEVISE_DYNAMODB_LIBRARY, Devise.dynamodb_library.to_sym
    end

    test "ships a fallback :taken translation that applications can override" do
      assert_equal "has already been taken", I18n.t("errors.messages.taken", locale: :en)
      fallback = File.expand_path("../../lib/devise/orm/dynamodb/locale/en.yml", __dir__)
      assert_includes I18n.load_path.map(&:to_s), fallback

      store_translations :en, errors: { messages: { taken: "is in use" } } do
        first = create_user
        duplicate = new_user(email: first.email)
        assert duplicate.invalid?
        assert_equal ["is in use"], duplicate.errors[:email]
      end
    end

    test "library returns the configured library" do
      swap Devise, dynamodb_library: :dynamoid do
        assert_equal :dynamoid, Devise::Orm::Dynamodb.library
      end
    end

    test "library raises ArgumentError for an unknown value" do
      original = Devise.dynamodb_library
      begin
        Devise.dynamodb_library = :nosuchlib
        error = assert_raises(ArgumentError) { Devise::Orm::Dynamodb.library }
        assert_match(/Unknown Devise.dynamodb_library/, error.message)
      ensure
        Devise.dynamodb_library = original
      end
    end

    test "Devise::Orm.dynamodb? is true for a Dynamoid model" do
      assert Devise::Orm.dynamodb?(User)
    end

    test "Devise::Orm.dynamodb? is false for a plain class" do
      refute Devise::Orm.dynamodb?(Class.new)
    end

    test "Devise::Orm.dynamodb? is false for a non-class" do
      refute Devise::Orm.dynamodb?(User.new)
    end
  end
end
