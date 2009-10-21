ENV["RAILS_ENV"] = "test"
require File.join(File.dirname(__FILE__), 'rails_app', 'config', 'environment')

require 'test_help'
require 'webrat'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = 'test.com'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Schema.define(:version => 1) do
  [:users, :admins].each do |table|
    create_table table do |t|
      t.authenticable

      if table == :users
        t.confirmable
        t.recoverable
        t.rememberable
      end

      t.timestamps
    end
  end
end

Webrat.configure do |config|
  config.mode = :rails
end

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end
