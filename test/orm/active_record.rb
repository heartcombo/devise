# frozen_string_literal: true

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.include_root_in_json = true

migrate_path = File.expand_path("../../rails_app/db/migrate/", __FILE__)
if Devise::Test.rails52_and_up?
  ActiveRecord::MigrationContext.new(migrate_path).migrate
else
  ActiveRecord::Migrator.migrate(migrate_path)
end

class ActiveSupport::TestCase
  self.use_transactional_tests = true

  self.use_instantiated_fixtures  = false
end
