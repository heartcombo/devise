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
      t.string   :email,              :null => false
      t.string   :encrypted_password, :null => false
      t.string   :password_salt,      :null => false
      if table == :users
        t.string   :confirmation_token
        t.datetime :confirmation_sent_at
        t.datetime :confirmed_at
        t.string   :reset_password_token
        t.string   :remember_token
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
