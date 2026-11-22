# frozen_string_literal: true

require "test_helper"
require "generators/dynamodb/devise_generator"
require "generators/dynamoid/devise_generator"
require "generators/aws_record/devise_generator"

# These generators don't touch the database, so they run with every ORM.
class DynamodbGeneratorTest < Rails::Generators::TestCase
  tests Dynamodb::Generators::DeviseGenerator
  destination File.expand_path("../../tmp", __FILE__)
  setup :prepare_destination

  # The default library comes from Devise.dynamodb_library, which the
  # aws_record test run changes. Use the gem default here.
  setup do
    @previous_library = Devise.dynamodb_library
    Devise.dynamodb_library = :dynamoid
  end

  teardown do
    Devise.dynamodb_library = @previous_library
  end

  test "creates a Dynamoid model by default" do
    run_generator %w(monster)
    assert_file "app/models/monster.rb" do |content|
      assert_match(/class Monster\n  include Dynamoid::Document/, content)
      assert_match(/field :email,\s+:string, default: ""/, content)
      assert_match(/field :encrypted_password, :string, default: ""/, content)
      assert_match(/global_secondary_index hash_key: :email, projected_attributes: :all/, content)
      assert_match(/devise :database_authenticatable, :registerable,/, content)
    end
    assert_no_directory "db/migrate"
  end

  test "creates an aws-record model with --library=aws_record" do
    run_generator %w(monster --library=aws_record)
    assert_file "app/models/monster.rb" do |content|
      assert_match(/include Aws::Record\n  include Devise::Orm::Dynamodb::AwsRecordModel/, content)
      assert_match(/string_attr :id, hash_key: true/, content)
      assert_match(/string_attr :email\n/, content)
      assert_match(/global_secondary_index :email_index, hash_key: :email, projection: \{ projection_type: "ALL" \}/, content)
      assert_match(/devise :database_authenticatable/, content)
    end
  end

  test "generated models include the fields of the 7 supported modules" do
    run_generator %w(monster)
    assert_file "app/models/monster.rb" do |content|
      %w(reset_password_token remember_created_at sign_in_count confirmation_token
         unconfirmed_email failed_attempts unlock_token locked_at).each do |field|
        assert_match(/field :#{field}/, content)
      end
    end
  end

  test "creates namespaced models" do
    run_generator %w(admin/monster)
    assert_file "app/models/admin/monster.rb", /class Admin::Monster/
  end

  test "injects devise into an existing Dynamoid model" do
    write_model "monster", "class Monster\n  include Dynamoid::Document\n\n  field :name\nend\n"
    run_generator %w(monster)
    assert_file "app/models/monster.rb" do |content|
      assert_match(/include Dynamoid::Document\n  ## Database authenticatable/, content)
      assert_match(/devise :database_authenticatable/, content)
      assert_match(/field :name/, content)
    end
  end

  test "injects devise into an existing aws-record model" do
    write_model "monster", "class Monster\n  include Aws::Record\n  string_attr :id, hash_key: true\nend\n"
    run_generator %w(monster --library=aws_record)
    assert_file "app/models/monster.rb" do |content|
      assert_match(/include Aws::Record\n  ## Database authenticatable\n  string_attr :email/, content)
      assert_match(/devise :database_authenticatable/, content)
    end
  end

  test "does not inject devise twice" do
    run_generator %w(monster)
    run_generator %w(monster)
    assert_file "app/models/monster.rb" do |content|
      assert_equal 1, content.scan("devise :database_authenticatable").size
    end
  end

  test "uses Devise.dynamodb_library as default library" do
    swap Devise, dynamodb_library: :aws_record do
      run_generator %w(monster)
    end
    assert_file "app/models/monster.rb", /include Aws::Record/
  end

  test "fails with an unknown library" do
    content = capture(:stderr) { run_generator %w(monster --library=cassandra) }
    assert_match(/Unknown DynamoDB library "cassandra"/, content)
    assert_no_file "app/models/monster.rb"
  end

  test "all files are properly deleted" do
    run_generator %w(monster)
    run_generator %w(monster), behavior: :revoke
    assert_no_file "app/models/monster.rb"
  end

  private

  def write_model(name, content)
    path = File.join(destination_root, "app/models/#{name}.rb")
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end
end

class DynamoidGeneratorTest < Rails::Generators::TestCase
  tests Dynamoid::Generators::DeviseGenerator
  destination File.expand_path("../../tmp", __FILE__)
  setup :prepare_destination

  test "always generates a Dynamoid model" do
    swap Devise, dynamodb_library: :aws_record do
      run_generator %w(monster)
    end
    assert_file "app/models/monster.rb", /include Dynamoid::Document/
  end
end

class AwsRecordGeneratorTest < Rails::Generators::TestCase
  tests AwsRecord::Generators::DeviseGenerator
  destination File.expand_path("../../tmp", __FILE__)
  setup :prepare_destination

  test "always generates an aws-record model" do
    run_generator %w(monster)
    assert_file "app/models/monster.rb", /include Aws::Record/
  end
end
