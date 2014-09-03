require "test_helper"

class ControllersGeneratorTest < Rails::Generators::TestCase
  tests Devise::Generators::ControllersGenerator
  destination File.expand_path("../../tmp", __FILE__)
  setup :prepare_destination

  test "Assert all controllers are properly created with no params" do
    run_generator
    assert_class_names
  end

  test "Assert all controllers are properly created with scope param" do
    run_generator %w(users)
    assert_class_names 'users'

    run_generator %w(admins)
    assert_class_names 'admins'
  end

  test "Assert only controllers with specific names" do
    run_generator %w(-c sessions registrations)
    assert_file "app/controllers/sessions_controller.rb"
    assert_file "app/controllers/registrations_controller.rb"
    assert_no_file "app/controllers/confirmations_controller.rb"
    assert_no_file "app/controllers/passwords_controller.rb"
    assert_no_file "app/controllers/unlocks_controller.rb"
    assert_no_file "app/controllers/omniauth_callbacks_controller.rb"
  end

  test "Assert specified controllers with scope" do
    run_generator %w(users -c sessions)
    assert_file "app/controllers/users/sessions_controller.rb"
    assert_no_file "app/controllers/users/confirmations_controller.rb"
  end

  private

    def assert_class_names(scope = nil, options = {})
      base_dir = "app/controllers#{scope.blank? ? '' : ('/' + scope)}"
      scope_prefix = scope.blank? ? '' : (scope.camelize + '::')
      controllers = options[:controllers] ||
        %w(confirmations passwords registrations sessions unlocks omniauth_callbacks)

      controllers.each do |c|
        assert_file "#{base_dir}/#{c}_controller.rb", /#{scope_prefix + c.camelize}/
      end
    end
end
