# frozen_string_literal: true

require "test_helper"

class InstallGeneratorTest < Rails::Generators::TestCase
  tests Devise::Generators::InstallGenerator
  destination File.expand_path("../../tmp", __FILE__)
  setup :prepare_destination

  test "assert all files are properly created" do
    run_generator(["--orm=active_record"])
    assert_file "config/initializers/devise.rb", /devise\/orm\/active_record/
    assert_file "config/locales/devise.en.yml"
  end

  test "configures DynamoDB with Dynamoid by default" do
    run_generator(["--orm=dynamodb"])
    assert_file "config/initializers/devise.rb" do |content|
      assert_match(/config\.dynamodb_library = :dynamoid/, content)
      assert_match(/require 'devise\/orm\/dynamodb'/, content)
    end
  end

  test "configures DynamoDB with Dynamoid for --orm=dynamoid" do
    run_generator(["--orm=dynamoid"])
    assert_file "config/initializers/devise.rb", /config\.dynamodb_library = :dynamoid\n  require 'devise\/orm\/dynamodb'/
  end

  test "configures DynamoDB with aws-record for --orm=aws_record" do
    run_generator(["--orm=aws_record"])
    assert_file "config/initializers/devise.rb", /config\.dynamodb_library = :aws_record\n  require 'devise\/orm\/dynamodb'/
  end

  test "does not configure DynamoDB for other ORMs" do
    run_generator(["--orm=active_record"])
    assert_file "config/initializers/devise.rb" do |content|
      assert_no_match(/dynamodb_library/, content)
    end
  end

  test "fails if no ORM is specified" do
    stderr = capture(:stderr) do
      run_generator
    end

    assert_match %r{An ORM must be set to install Devise}, stderr

    assert_no_file "config/initializers/devise.rb"
    assert_no_file "config/locales/devise.en.yml"
  end

  test "responder error_status based on rack version" do
    run_generator(["--orm=active_record"])

    error_status = Rack::RELEASE >= "3.1" ? :unprocessable_content : :unprocessable_entity

    assert_file "config/initializers/devise.rb", /config\.responder\.error_status = #{error_status.inspect}/
  end
end
