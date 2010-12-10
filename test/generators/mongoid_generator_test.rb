require File.expand_path("../generators_test_helper", __FILE__)

if DEVISE_ORM == :mongoid
  class MongoidGeneratorTest < Rails::Generators::TestCase
    tests Mongoid::Generators::DeviseGenerator
    destination File.expand_path("../../tmp", __FILE__)
    setup :prepare_destination
  
    test "all files are properly created" do
      run_generator %w(monster)
      assert_file "app/models/monster.rb", /devise/
    end
  
    test "all files are properly deleted" do
      run_generator %w(monster)
      run_generator %w(monster), :behavior => :revoke
      assert_no_file "app/models/monster.rb"
    end
  end
end