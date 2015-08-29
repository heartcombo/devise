require 'test_helper'

class ApiController < ActionController::Metal
  include Devise::Controllers::Helpers
end

class HelperMethodsTest < ActionController::TestCase
  tests ApiController

  test 'includes Devise::Controllers::Helpers' do
    assert @controller.class.ancestors.include?(Devise::Controllers::Helpers)
  end

  test 'does not respond_to helper_method' do
    refute @controller.respond_to?(:helper_method)
  end

  test 'defines methods like current_user' do
    assert @controller.respond_to?(:current_user)
  end
end
