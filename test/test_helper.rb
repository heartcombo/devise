RAILS_ENV = ENV["RAILS_ENV"] = "test"

require 'test/unit'
require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'action_mailer'
require 'active_record'

require File.join(File.dirname(__FILE__), '..', 'lib', 'devise')

ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Schema.define(:version => 1) do
  create_table :users do |t|
    t.string :email,              :null => false
    t.string :encrypted_password, :null => false
    t.string :password_salt,      :null => false
    t.string :confirmation_token, :null => false
    t.datetime :confirmed_at
  end
end

class User < ::ActiveRecord::Base
  include ::Devise::Authenticable
  include ::Devise::Confirmable
end

ActionMailer::Base.delivery_method = :test
#ActionMailer::Base.delivery_method = :test
#ActionMailer::Base.perform_deliveries = true
#ActionMailer::Base.deliveries = []

class ActiveSupport::TestCase
  def assert_not(assertion)
    assert !assertion
  end

  def assert_blank(assertion)
    assert assertion.blank?
  end

  def assert_not_blank(assertion)
    assert !assertion.blank?
  end
  alias :assert_present :assert_not_blank

  # Helpers for creating new users
  #
  def generate_unique_email
    @@email_count ||= 0
    @@email_count += 1
    "test#{@@email_count}@email.com"
  end

  def valid_attributes(attributes={})
    { :email => generate_unique_email,
      :password => '12345',
      :password_confirmation => '12345' }.update(attributes)
  end

  def new_user(attributes={})
    User.new(valid_attributes(attributes))
  end

  def create_user(attributes={})
    User.create!(valid_attributes(attributes))
  end

  def field_accessible?(field)
    new_user(field => 'test').send(field) == 'test'
  end
end

