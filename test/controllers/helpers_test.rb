require 'test/test_helper'

class HelpersTest < ActionController::TestCase
  tests ApplicationController

  test 'get resource name from request path' do
    @request.path = '/users/session'
    assert_equal :user, @controller.resource_name
  end

  test 'get translated resource name from request path' do
    @request.path = '/admin_area/session'
    assert_equal :admin, @controller.resource_name
  end

  test 'get resource class from request path' do
    @request.path = '/users/session'
    assert_equal User, @controller.resource_class
  end

  test 'get resource ivar from request path' do
    @request.path = '/admin_area/session'
    @controller.instance_variable_set(:@admin, admin = Admin.new)
    assert_equal admin, @controller.resource
  end

  test 'set resource ivar from request path' do
    @request.path = '/admin_area/session'

    admin = @controller.send(:resource_class).new
    @controller.send(:resource=, admin)

    assert_equal admin, @controller.send(:resource)
    assert_equal admin, @controller.instance_variable_get(:@admin)
  end

  test 'resources methods are not controller actions' do
    assert @controller.class.action_methods.empty?
  end
end
