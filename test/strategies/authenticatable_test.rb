# frozen_string_literal: true

require 'test_helper'
require 'devise/strategies/database_authenticatable'
require 'devise/strategies/rememberable'

class AuthenticatableStrategyTest < ActiveSupport::TestCase
  test 'authenticatable_name comes from the strategy class name' do
    assert_equal :database, Devise::Strategies::DatabaseAuthenticatable.authenticatable_name
    assert_equal :rememberable, Devise::Strategies::Rememberable.authenticatable_name
    assert_equal :database, Devise::Strategies::DatabaseAuthenticatable.new({}).send(:authenticatable_name)
  end

  test 'authenticatable_name is computed once per strategy class, not per instance' do
    Devise::Strategies::DatabaseAuthenticatable.authenticatable_name
    ActiveSupport::Inflector.expects(:underscore).never
    2.times { Devise::Strategies::DatabaseAuthenticatable.new({}).send(:authenticatable_name) }
  end
end
