require "test_helper"

class InstallGeneratorTest < Rails::Generators::TestCase
  tests Devise::Generators::InstallGenerator
  destination File.expand_path("../../tmp", __FILE__)
  setup :prepare_destination

  test "Assert all files are properly created" do
    run_generator(['--orm=active_record'])
    assert_file "config/initializers/devise.rb", /devise\/orm\/active_record/
    assert_file "config/locales/devise.en.yml"
  end

  test "Fail if no ORM is specified" do
    error = assert_raises RuntimeError do
      run_generator
    end

    assert_match /An ORM must be set to install Devise/, error.message
  end
end
