require 'test/test_helper'

class ResourcesTest < ActionController::TestCase
  tests ApplicationController

  test 'should get resource name from request path' do
    @request.path = '/users/session'
    assert_equal 'users', @controller.resource_name
  end

  test 'should get translated resource name from request path' do
    @request.path = '/conta/session'
    assert_equal 'account', @controller.resource_name
  end

  test 'should get resource class from request path' do
    @request.path = '/users/session'
    assert_equal User, @controller.resource_class
  end
end
