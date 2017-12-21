# frozen_string_literal: true

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.include_root_in_json = true

ActiveRecord::Migrator.migrate(File.expand_path("../../rails_app/db/migrate/", __FILE__))

class ActiveSupport::TestCase
  if Devise::Test.rails5?
    self.use_transactional_tests = true
  else
    # Let `after_commit` work with transactional fixtures, however this is not needed for Rails 5.
    require 'test_after_commit'
    self.use_transactional_fixtures = true
  end

  self.use_instantiated_fixtures  = false
end
