require 'test_helper'

class MyController < ApplicationController
  include Devise::Controllers::InternalHelpers
end

class HelpersTest < ActionController::TestCase
  tests MyController

  def setup
    @mock_warden = OpenStruct.new
    @controller.request.env['warden'] = @mock_warden
    @controller.request.env['devise.mapping'] = Devise.mappings[:user]
  end

  test 'get resource name from env' do
    assert_equal :user, @controller.resource_name
  end

  test 'get resource class from env' do
    assert_equal User, @controller.resource_class
  end

  test 'get resource instance variable from env' do
    @controller.instance_variable_set(:@user, admin = Admin.new)
    assert_equal admin, @controller.resource
  end

  test 'set resource instance variable from env' do
    admin = @controller.send(:resource_class).new
    @controller.send(:resource=, admin)

    assert_equal admin, @controller.send(:resource)
    assert_equal admin, @controller.instance_variable_get(:@user)
  end

  test 'resources methods are not controller actions' do
    assert @controller.class.action_methods.empty?
  end

  test 'require no authentication tests current mapping' do
    @controller.expects(:resource_name).returns(:user).twice
    @mock_warden.expects(:authenticated?).with(:user).returns(true)
    @controller.expects(:redirect_to).with(root_path)
    @controller.send :require_no_authentication
  end
  
  test 'is a devise controller' do
    assert @controller.devise_controller?
  end
end
