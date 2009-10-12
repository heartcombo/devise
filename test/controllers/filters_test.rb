require 'test/test_helper'
require 'ostruct'

class MockController < ApplicationController
  attr_accessor :env

  def request
    self
  end

  def path
    ''
  end
end

class ControllerAuthenticableTest < ActionController::TestCase

  def setup
    @controller = MockController.new
    @mock_warden = OpenStruct.new
    @controller.env = { 'warden' => @mock_warden }
  end

  test 'setup warden' do
    assert_not_nil @controller.warden
  end

  test 'provide access to warden instance' do
    assert_equal @controller.warden, @controller.env['warden']
  end

  test 'run authenticate? with scope on warden' do
    @mock_warden.expects(:authenticated?).with(:my_scope)
    @controller.authenticated?(:my_scope)
  end

  test 'proxy signed_in? to authenticated' do
    @mock_warden.expects(:authenticated?).with(:my_scope)
    @controller.signed_in?(:my_scope)
  end

  test 'run user with scope on warden' do
    @mock_warden.expects(:user).with(:admin).returns(true)
    @controller.current_admin

    @mock_warden.expects(:user).with(:user).returns(true)
    @controller.current_user
  end

  test 'proxy logout to warden' do
    @mock_warden.expects(:logout).with(:user).returns(true)
    @controller.logout(:user)
  end

  test 'proxy user_authenticate! to authenticate with user scope' do
    @mock_warden.expects(:authenticate!).with(:scope => :user)
    @controller.user_authenticate!
  end

  test 'proxy admin_authenticate! to authenticate with admin scope' do
    @mock_warden.expects(:authenticate!).with(:scope => :admin)
    @controller.admin_authenticate!
  end

  test 'proxy user_authenticated? to authenticate with user scope' do
    @mock_warden.expects(:authenticated?).with(:user)
    @controller.user_authenticated?
  end

  test 'proxy admin_authenticated? to authenticate with admin scope' do
    @mock_warden.expects(:authenticated?).with(:admin)
    @controller.admin_authenticated?
  end

  test 'require no authentication tests current mapping' do
    @controller.expects(:resource_name).returns(:user)
    @mock_warden.expects(:authenticated?).with(:user).returns(true)
    @controller.expects(:redirect_to).with(root_path)
    @controller.require_no_authentication
  end
end
