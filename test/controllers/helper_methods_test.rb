# frozen_string_literal: true

require 'test_helper'

class ApiController < ActionController::Metal
  include Devise::Controllers::Helpers
  include Devise::Views::Helpers
end

class HelperMethodsTest < Devise::ControllerTestCase
  tests ApiController

  test 'includes Devise::Controllers::Helpers' do
    assert_includes @controller.class.ancestors, Devise::Controllers::Helpers
  end

  test 'includes Devise::Views::Helpers' do
    assert_includes @controller.class.ancestors, Devise::Views::Helpers
  end

  test 'does not respond_to helper or helper_method' do
    refute_respond_to @controller.class, :helper
    refute_respond_to @controller.class, :helper_method
  end

  test 'defines methods like current_user' do
    assert_respond_to @controller, :current_user
  end

  test 'defines methods like signed_in_user' do
    assert_respond_to @controller, :signed_in_user
  end

end
