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

  test 'run authenticate? on warden' do
    @mock_warden.expects(:authenticated?).returns(true)
    @controller.authenticated?
  end

  test 'run authenticate? with scope on warden' do
    @mock_warden.expects(:authenticated?).with(:my_scope)
    @controller.authenticated?(:my_scope)
  end

  test 'proxy signed_in? to authenticated' do
    @mock_warden.expects(:authenticated?).with(:my_scope)
    @controller.signed_in?(:my_scope)
  end

  test 'run user on warden' do
    @mock_warden.expects(:user).returns(true)
    @controller.current_user
  end

  test 'run user with scope on warden' do
    @mock_warden.expects(:user).with(:admin).returns(true)
    @controller.current_user(:admin)
  end

  test 'set the user on warden' do
    @mock_warden.expects(:set_user).returns(true)
    @controller.current_user = User.new
  end

  test 'proxy logout to warden' do
    @mock_warden.expects(:logout).returns(true)
    @controller.logout
  end
end
