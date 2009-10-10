require 'test/test_helper'

class ResourcesTest < ActionController::TestCase
  tests ApplicationController

  test 'get resource name from request path' do
    @request.path = '/users/session'
    assert_equal 'user', @controller.resource_name
  end

  test 'get translated resource name from request path' do
    @request.path = '/conta/session'
    assert_equal 'account', @controller.resource_name
  end

  test 'get resource class from request path' do
    @request.path = '/users/session'
    assert_equal User, @controller.resource_class
  end

  test 'get resource ivar from request path' do
    @request.path = '/conta/session'
    @controller.instance_variable_set(:@account, account = Account.new)
    assert_equal account, @controller.resource
    assert_equal account, @controller.instance_variable_get(:@resource)
  end

  test 'set resource ivar from request path' do
    @request.path = '/conta/session'
    @controller.resource = account = @controller.resource_class.new
    assert_equal account, @controller.resource
    assert_equal account, @controller.instance_variable_get(:@resource)
  end
end
