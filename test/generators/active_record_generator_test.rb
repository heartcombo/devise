require "test_helper"

if DEVISE_ORM == :active_record
  require "generators/active_record/devise_generator"

  class ActiveRecordGeneratorTest < Rails::Generators::TestCase
    tests ActiveRecord::Generators::DeviseGenerator
    destination File.expand_path("../../tmp", __FILE__)
    setup :prepare_destination

    test "all files are properly created with rails31 migration syntax" do
      run_generator %w(monster)
      assert_migration "db/migrate/devise_create_monsters.rb", /def change/
    end

    test "all files for namespaced model are properly created" do
      run_generator %w(admin/monster)
      assert_migration "db/migrate/devise_create_admin_monsters.rb", /def change/
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
      run_generator %w(monster), behavior: :revoke
      assert_no_migration "db/migrate/add_devise_to_monsters.rb"
      assert_migration "db/migrate/devise_create_monsters.rb"
      run_generator %w(monster), behavior: :revoke
      assert_no_file "app/models/monster.rb"
      assert_no_migration "db/migrate/devise_create_monsters.rb"
    end

    test "use string column type for ip addresses" do
      run_generator %w(monster)
      assert_migration "db/migrate/devise_create_monsters.rb", /t.string   :current_sign_in_ip/
      assert_migration "db/migrate/devise_create_monsters.rb", /t.string   :last_sign_in_ip/
    end
  end

  module RailsEngine
    class Engine < Rails::Engine
      isolate_namespace RailsEngine
    end
  end

  def simulate_inside_engine(engine, namespace)
    if Rails::Generators.respond_to?(:namespace=)
      swap Rails::Generators, namespace: namespace do
        yield
      end
    else
      swap Rails, application: engine.instance do
        yield
      end
    end
  end

  class ActiveRecordEngineGeneratorTest < Rails::Generators::TestCase
    tests ActiveRecord::Generators::DeviseGenerator
    destination File.expand_path("../../tmp", __FILE__)
    setup :prepare_destination

    test "all files are properly created in rails 4.0" do
      simulate_inside_engine(RailsEngine::Engine, RailsEngine) do
        run_generator ["monster"]

        assert_file "app/models/rails_engine/monster.rb", /devise/
        assert_file "app/models/rails_engine/monster.rb" do |content|
          assert_no_match %r{attr_accessible :email}, content
        end
      end
    end

  end
end
