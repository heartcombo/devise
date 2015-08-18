ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.include_root_in_json = true

ActiveRecord::Migrator.migrate(File.expand_path("../../rails_app/db/migrate/", __FILE__))

class ActiveSupport::TestCase
  if Rails.version >= '5.0.0'
    self.use_transactional_tests = true
  else
    self.use_transactional_fixtures = true
  end

  self.use_instantiated_fixtures  = false
end
