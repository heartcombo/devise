require 'test_helper'

require "generators/devise/devise_generator"

class DeviseGeneratorTest < Rails::Generators::TestCase
  tests Devise::Generators::DeviseGenerator
  destination File.expand_path("../../tmp", __FILE__)

  setup do
    prepare_destination
    copy_routes
  end

  test "route generation for simple model names" do
    run_generator %w(monster name:string)
    assert_file "config/routes.rb", /devise_for :monsters/
  end

  def copy_routes
    routes = File.expand_path("../../rails_app/config/routes.rb", __FILE__)
    destination = File.join(destination_root, "config")

    FileUtils.mkdir_p(destination)
    FileUtils.cp routes, destination
  end

end
