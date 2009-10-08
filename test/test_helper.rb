RAILS_ENV = ENV["RAILS_ENV"] = "test"
require File.join(File.dirname(__FILE__), 'rails_app', 'config', 'environment')

require 'test_help'

require 'webrat'

require 'assertions_helper'
require 'models_helper'
require 'integration_tests_helper'
require 'model_builder'

ActiveSupport::Dependencies.load_paths << File.expand_path(File.dirname(__FILE__) + '/../lib')
require_dependency 'devise'

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Schema.define(:version => 1) do
  create_table :users do |t|
    t.string :email,              :null => false
    t.string :encrypted_password, :null => false
    t.string :password_salt,      :null => false
    t.string :perishable_token
    t.datetime :confirmed_at
  end
end

Webrat.configure do |config|
  config.mode = :rails
end

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end
