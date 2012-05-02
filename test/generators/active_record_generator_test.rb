require "test_helper"

if DEVISE_ORM == :active_record
  require "generators/active_record/devise_generator"

  class ActiveRecordGeneratorTest < Rails::Generators::TestCase
    tests ActiveRecord::Generators::DeviseGenerator
    destination File.expand_path("../../tmp", __FILE__)
    setup :prepare_destination

    test "all files are properly created with rails31 migration syntax" do
      run_generator %w(monster)
      assert_file "app/models/monster.rb", /devise/, /attr_accessible (:[a-z_]+(, )?)+/
      assert_migration "db/migrate/devise_create_monsters.rb", /def change/
    end

    test "update model migration when model exists" do
      run_generator %w(monster)
      assert_file "app/models/monster.rb"
      run_generator %w(monster)
      assert_migration "db/migrate/add_devise_to_monsters.rb"
    end

    test "all files are properly deleted" do
      run_generator %w(monster)
      run_generator %w(monster)
      assert_migration "db/migrate/devise_create_monsters.rb"
      assert_migration "db/migrate/add_devise_to_monsters.rb"
      run_generator %w(monster), :behavior => :revoke
      assert_no_migration "db/migrate/add_devise_to_monsters.rb"
      assert_migration "db/migrate/devise_create_monsters.rb"
      run_generator %w(monster), :behavior => :revoke
      assert_no_file "app/models/monster.rb"
      assert_no_migration "db/migrate/devise_create_monsters.rb"
    end
  end

  module RailsEngine
    class Engine < Rails::Engine
      isolate_namespace RailsEngine
    end
  end

  class ActiveRecordEngineGeneratorTest < Rails::Generators::TestCase
    tests ActiveRecord::Generators::DeviseGenerator
    destination File.expand_path("../../tmp", __FILE__)
    setup :prepare_destination

    test "all files are properly created" do
      swap Rails, :application => RailsEngine::Engine.instance do
        run_generator ["monster"]

        assert_file "app/models/rails_engine/monster.rb", /devise/,  /attr_accessible (:[a-z_]+(, )?)+/
      end
    end
  end
end