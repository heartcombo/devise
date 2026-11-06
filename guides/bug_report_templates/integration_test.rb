# frozen_string_literal: true

require 'bundler/inline'

gemfile(true) do
  source 'https://rubygems.org'
  # Activate the gem you are reporting the issue against.
  gem 'rails', '~> 8.1.0'
  gem 'devise', '~> 5.0'
  gem 'sqlite3'
  gem 'byebug'
end

require 'rack/test'
require 'action_controller/railtie'
require 'active_record'
require 'devise/rails/routes'
require 'devise/rails/warden_compat'

ActiveRecord::Base.establish_connection( adapter: :sqlite3, database:  ':memory:')

class DeviseCreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table(:users) do |t|
      t.string :email,              null: false
      t.string :encrypted_password, null: true
      t.timestamps null: false
    end

  end
end

DeviseCreateUsers.migrate(:up)

Devise.setup do |config|
  require 'devise/orm/active_record'
  config.secret_key = 'secret_key_base'
end

class User < ActiveRecord::Base
  devise :database_authenticatable
end

class TestApp < Rails::Application
  config.root = File.dirname(__FILE__)
  config.session_store :cookie_store, key: 'cookie_store_key'
  config.secret_key_base = 'secret_key_base'
  config.eager_load = false
  config.hosts << 'example.org'

  config.logger = Logger.new($stdout)
  Rails.logger  = config.logger
end

# Use `prepend` instead of `draw`: in development Rails loads the routes lazily,
# and `draw` would first finalize an empty route set, at which point Devise
# configures Warden once without any mapping. Prepended blocks run as part of
# that lazy load, so `devise_for` is known when the routes are finalized.
Rails.application.routes.prepend do
  devise_for :users

  get '/' => 'test#index'
end

Rails.application.initialize!

class ApplicationController < ActionController::Base
end

class TestController < ApplicationController
  include Rails.application.routes.url_helpers

  before_action :authenticate_user!

  def index
    render plain: 'Home'
  end
end

require 'minitest/autorun'

class BugTest < ActionDispatch::IntegrationTest
  include Rack::Test::Methods
  include Warden::Test::Helpers

  def test_returns_success
    Warden.test_mode!

    login_as User.create!(email: 'test@test.com', password: 'test123456', password_confirmation: 'test123456')

    get '/'
    assert last_response.ok?
  end

  private

  def app
    Rails.application
  end
end
