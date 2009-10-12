require 'test/test_helper'

class FiltersController < ApplicationController
  before_filter :user_authenticate!, :only => :user_action
  before_filter :admin_authenticate!, :only => :admin_action
  before_filter :require_no_authentication, :only => :not_authenticated_action

  def public_action
    render :text => 'public'
  end

  def not_authenticated_action
    render :text => 'not_authenticated'
  end

  def user_action
    render :text => 'user'
  end

  def admin_action
    render :text => 'admin'
  end
end

class FiltersTest < ActionController::TestCase
  tests FiltersController

#  test 'generate user_authenticate! filter' do
#    assert @controller.respond_to?(:user_authenticate!)
#  end

#  test 'proxy user_authenticate! to authenticate with user scope' do
#    @controller.expects(:authenticate!).with('user')
#    @controller.user_authenticate!
#  end

#  test 'generate admin_authenticate! filter' do
#    assert @controller.respond_to?(:admin_authenticate!)
#  end

#  test 'proxy admin_authenticate! to authenticate with user scope' do
#    @controller.expects(:authenticate!).with('admin')
#    @controller.admin_authenticate!
#  end

#  test 'not authenticated user should be able to access public action' do
#    get :public_action

#    assert_response :success
#    assert_equal 'public', @response.body
#  end

#  test 'not authenticated as user should not be able to access user action' do
#    @controller.expects(:authenticated?).with('user').returns(false)

#    get :user_action
#    assert_response :redirect
#    assert_redirected_to new_user_session_path
#  end

#  test 'authenticated as user should be able to access user action' do
#    @controller.expects(:authenticated?).with('user').returns(true)

#    get :user_action
#    assert_response :success
#    assert_equal 'user', @response.body
#  end

#  test 'not authenticated as admin should not be able to access admin action' do
#    @controller.expects(:authenticated?).with('admin').returns(false)

#    get :admin_action
#    assert_response :redirect
#    assert_redirected_to new_admin_session_path
#  end

#  test 'authenticated as admin should be able to access admin action' do
#    @controller.expects(:authenticated?).with('admin').returns(true)

#    get :admin_action
#    assert_response :success
#    assert_equal 'admin', @response.body
#  end

#  test 'authenticated as user should not be able to access not authenticated action' do
#    @controller.expects(:authenticated?).with('user').returns(true)
#    @controller.expects(:authenticated?).with('admin').returns(false)

#    get :not_authenticated_action
#    assert_response :redirect
#    assert_redirected_to root_path
#  end

#  test 'authenticated as admin should not be able to access not authenticated action' do
#    @controller.expects(:authenticated?).with('user').returns(false)
#    @controller.expects(:authenticated?).with('admin').returns(true)

#    get :not_authenticated_action
#    assert_response :redirect
#    assert_redirected_to root_path
#  end

#  test 'not authenticated should access not_authenticated_action' do
#    @controller.expects(:authenticated?).with('user').returns(false)
#    @controller.expects(:authenticated?).with('admin').returns(false)

#    get :not_authenticated_action
#    assert_response :success
#    assert_equal 'not_authenticated', @response.body
#  end
end
