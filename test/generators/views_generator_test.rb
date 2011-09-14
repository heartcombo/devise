require "test_helper"

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

  test "Assert views with simple form" do
    run_generator %w(-b simple_form_for)
    assert_files
    assert_file "app/views/devise/confirmations/new.html.erb", :template_engine => /simple_form_for/

    run_generator %w(users -b simple_form_for)
    assert_files "users"
    assert_file "app/views/users/confirmations/new.html.erb", :template_engine => /simple_form_for/
  end

  test "Assert views with markerb" do
    run_generator %w(--markerb)
    assert_files nil, :mail_template_engine => "markerb"
  end

  test "Assert Gemfile got gem markerb injected" do
    File.open(File.join(destination_root, "Gemfile"), 'w') {|f| f.write("gem 'rails'") }
    run_generator %w(--markerb)
    assert_file "Gemfile", /gem \"markerb\"/
  end

  test "Assert Gemfile got created with markerb if no gemfile" do
    run_generator %w(--markerb)
    assert_file "Gemfile", /gem \"markerb\"/
  end

  def assert_files(scope = nil, options={})
    scope = "devise" if scope.nil?
    default_template = "html.erb"
    template_engine = options[:template_engine] || default_template
    mail_template_engine = options[:mail_template_engine] || default_template

    assert_file "app/views/#{scope}/confirmations/new.html.erb"
    assert_file "app/views/#{scope}/mailer/confirmation_instructions.#{mail_template_engine}"
    assert_file "app/views/#{scope}/mailer/reset_password_instructions.#{mail_template_engine}"
    assert_file "app/views/#{scope}/mailer/unlock_instructions.#{mail_template_engine}"
    assert_file "app/views/#{scope}/passwords/edit.html.erb"
    assert_file "app/views/#{scope}/passwords/new.html.erb"
    assert_file "app/views/#{scope}/registrations/new.html.erb"
    assert_file "app/views/#{scope}/registrations/edit.html.erb"
    assert_file "app/views/#{scope}/sessions/new.html.erb"
    assert_file "app/views/#{scope}/shared/_links.erb"
    assert_file "app/views/#{scope}/unlocks/new.html.erb"
  end
end
