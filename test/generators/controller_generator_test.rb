require "test_helper"

class ControllersGeneratorTest < Rails::Generators::TestCase
  tests Devise::Generators::ControllersGenerator
  destination File.expand_path("../../tmp", __FILE__)
  setup :prepare_destination

  test "Assert all controllers are properly created with no params" do
    run_generator
    assert_files
  end

  test "Assert all controllers are properly created with scope param param" do
    run_generator %w(users)
    assert_files "users"

    run_generator %w(admins)
    assert_files "admins"
  end

  def assert_files(scope = nil, template_engine = nil)
    scope = "devise" if scope.nil?
    assert_file "app/controllers/#{scope}/confirmations_controller.rb"
    assert_file "app/controllers/#{scope}/omniauth_callbacks_controller.rb"
    assert_file "app/controllers/#{scope}/passwords_controller.rb"
    assert_file "app/controllers/#{scope}/sessions_controller.rb"
    assert_file "app/controllers/#{scope}/unlocks_controller.rb"
  end
end