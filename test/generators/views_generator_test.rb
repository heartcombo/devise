require File.join(File.dirname(__FILE__),"generators_test_helper.rb")

class ViewsGeneratorTest < Rails::Generators::TestCase
  tests Devise::Generators::ViewsGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))
  setup :prepare_destination

  test "Assert all views are properly created with no params" do
    run_generator
    assert_file "app/views/devise/confirmations/new.html.erb" 
    assert_file "app/views/devise/mailer/confirmation_instructions.html.erb" 
    assert_file "app/views/devise/mailer/reset_password_instructions.html.erb" 
    assert_file "app/views/devise/mailer/unlock_instructions.html.erb" 
    assert_file "app/views/devise/passwords/edit.html.erb" 
    assert_file "app/views/devise/passwords/new.html.erb" 
    assert_file "app/views/devise/registrations/new.html.erb" 
    assert_file "app/views/devise/registrations/edit.html.erb" 
    assert_file "app/views/devise/sessions/new.html.erb" 
    assert_file "app/views/devise/shared/_links.erb" 
    assert_file "app/views/devise/unlocks/new.html.erb" 
  end

end
