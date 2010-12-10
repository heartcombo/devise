require File.expand_path("../generators_test_helper", __FILE__)

class ViewsGeneratorTest < Rails::Generators::TestCase
  tests Devise::Generators::ViewsGenerator
  destination File.expand_path("../../tmp", __FILE__)
  setup :prepare_destination

  test "Assert all views are properly created with no params" do
    run_generator
    assert_files
  end

  test "Assert all views are properly created with scope param param" do
    run_generator %w(users)
    assert_files "users"

    run_generator %w(admins)
    assert_files "admins"
  end

  def assert_files(scope = nil, template_engine = nil)
    scope = "devise" if scope.nil?
    assert_file "app/views/#{scope}/confirmations/new.html.erb"
    assert_file "app/views/#{scope}/mailer/confirmation_instructions.html.erb"
    assert_file "app/views/#{scope}/mailer/reset_password_instructions.html.erb"
    assert_file "app/views/#{scope}/mailer/unlock_instructions.html.erb"
    assert_file "app/views/#{scope}/passwords/edit.html.erb"
    assert_file "app/views/#{scope}/passwords/new.html.erb"
    assert_file "app/views/#{scope}/registrations/new.html.erb"
    assert_file "app/views/#{scope}/registrations/edit.html.erb"
    assert_file "app/views/#{scope}/sessions/new.html.erb"
    assert_file "app/views/#{scope}/shared/_links.erb"
    assert_file "app/views/#{scope}/unlocks/new.html.erb"
  end
end
