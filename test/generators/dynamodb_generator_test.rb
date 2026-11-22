# frozen_string_literal: true

require "test_helper"

if DEVISE_ORM == :dynamodb
  require "generators/dynamodb/devise_generator"

  class DynamodbGeneratorTest < Rails::Generators::TestCase
    tests Dynamodb::Generators::DeviseGenerator
    destination File.expand_path("../../tmp", __FILE__)
    setup :prepare_destination

    test "dynamoid model is created with devise content" do
      run_generator %w(monster --library=dynamoid)
      assert_file "app/models/monster.rb" do |content|
        assert_match(/include Dynamoid::Document/, content)
        assert_match(/field :email, :string/, content)
        assert_match(/field :email, :string, default: ""\n/, content)
        assert_match(/global_secondary_index hash_key: :email/, content)
        assert_match(/global_secondary_index hash_key: :reset_password_token/, content)
        assert_match(/devise :database_authenticatable/, content)
      end
    end

    test "aws_record model is created with devise content" do
      run_generator %w(monster --library=aws_record)
      assert_file "app/models/monster.rb" do |content|
        assert_match(/include Aws::Record/, content)
        assert_match(/string_attr :id, hash_key: true/, content)
        assert_match(/string_attr :email/, content)
        assert_match(/time_attr :remember_created_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime/, content)
        assert_match(/time_attr :created_at/, content)
        assert_no_match(/epoch_time_attr/, content)
        assert_match(/global_secondary_index :email_index, hash_key: :email/, content)
        assert_match(/devise :database_authenticatable/, content)
      end
    end

    test "dynamoid is the default library" do
      swap Devise, dynamodb_library: :dynamoid do
        run_generator %w(monster)
      end
      assert_file "app/models/monster.rb", /include Dynamoid::Document/
    end

    test "the library defaults to Devise.dynamodb_library" do
      swap Devise, dynamodb_library: :aws_record do
        run_generator %w(monster)
      end
      assert_file "app/models/monster.rb", /include Aws::Record/
    end

    test "existing model gets fields and devise injected after the include" do
      model = File.join(destination_root, "app/models/monster.rb")
      FileUtils.mkdir_p(File.dirname(model))
      File.write(model, "class Monster\n  include Dynamoid::Document\nend\n")

      run_generator %w(monster --library=dynamoid)
      assert_file "app/models/monster.rb" do |content|
        assert_match(/include Dynamoid::Document\n\n  ## Database authenticatable/, content)
        assert_match(/devise :database_authenticatable/, content)
      end
    end

    test "invalid library is rejected" do
      stderr = capture(:stderr) do
        run_generator %w(monster --library=couchbase)
      end
      assert_match(/Unknown DynamoDB library "couchbase"/, stderr)
      assert_no_file "app/models/monster.rb"
    end

    test "all files are properly deleted" do
      run_generator %w(monster --library=dynamoid)
      run_generator %w(monster --library=dynamoid), behavior: :revoke
      assert_no_file "app/models/monster.rb"
    end

    test "aws_record files are properly deleted" do
      run_generator %w(monster --library=aws_record)
      run_generator %w(monster --library=aws_record), behavior: :revoke
      assert_no_file "app/models/monster.rb"
    end
  end
end
