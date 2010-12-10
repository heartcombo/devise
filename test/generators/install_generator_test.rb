require File.expand_path("../generators_test_helper", __FILE__)

class InstallGeneratorTest < Rails::Generators::TestCase
  tests Devise::Generators::InstallGenerator
  destination File.expand_path("../../tmp", __FILE__)
  setup :prepare_destination

  test "Assert all files are properly created" do
    run_generator
    assert_file "config/initializers/devise.rb"
    assert_file "config/locales/devise.en.yml"
  end
end
