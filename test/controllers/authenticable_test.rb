require 'test/test_helper'
require 'ostruct'

class MockController < ApplicationController
  attr_accessor :env
  def request
    self
  end
end

class AuthenticableTest < ActionController::TestCase

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

  test 'run authenticate on warden' do
    @mock_warden.expects(:authenticate).returns(true)
    @controller.authenticate
  end

  test 'run authenticate! on warden' do
    @mock_warden.expects(:authenticate!).returns(true)
    @controller.authenticate!
  end

  test 'run authenticate? on warden' do
    @mock_warden.expects(:authenticated?).returns(true)
    @controller.authenticated?
  end

  test 'proxy logged_in? to authenticated' do
    @mock_warden.expects(:authenticated?).returns(true)
    @controller.logged_in?
  end

  test 'run user on warden' do
    @mock_warden.expects(:user).returns(true)
    @controller.user
  end

  test 'run current_user on warden' do
    @mock_warden.expects(:user).returns(true)
    @controller.current_user
  end

  test 'set the user on warden' do
    @mock_warden.expects(:set_user).returns(true)
    @controller.user = User.new
  end

  test 'proxy logout to warden' do
    @mock_warden.expects(:logout).returns(true)
    @controller.logout
  end
end
