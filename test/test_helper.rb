require 'test/unit'
require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'mocha'

require File.join(File.dirname(__FILE__), '..', 'lib', 'devise')

ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Schema.define(:version => 1) do
  create_table :users do |t|
    t.string :email,              :null => false
    t.string :encrypted_password, :null => false
    t.string :password_salt,      :null => false
  end
end

class User < ::ActiveRecord::Base
  include ::Devise::Authenticable
end

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
end

