require 'test/test_helper'

class RoutesTest < ActionController::TestCase
  tests ApplicationController

  def test_path_and_url(name, prepend_path=nil)
    @request.path = '/users/session'
    prepend_path = "#{prepend_path}_" if prepend_path

    # No params
    assert_equal @controller.send(:"#{prepend_path}#{name}_path", :user),
                 send(:"#{prepend_path}user_#{name}_path")
    assert_equal @controller.send(:"#{prepend_path}#{name}_url", :user),
                 send(:"#{prepend_path}user_#{name}_url")

    # Default url params
    assert_equal @controller.send(:"#{prepend_path}#{name}_path", :user, :param => 123),
                 send(:"#{prepend_path}user_#{name}_path", :param => 123)
    assert_equal @controller.send(:"#{prepend_path}#{name}_url", :user, :param => 123),
                 send(:"#{prepend_path}user_#{name}_url", :param => 123)

    @request.path = nil
    # With an AR object
    assert_equal @controller.send(:"#{prepend_path}#{name}_path", User.new),
                 send(:"#{prepend_path}user_#{name}_path")
    assert_equal @controller.send(:"#{prepend_path}#{name}_url", User.new),
                 send(:"#{prepend_path}user_#{name}_url")
  end


  test 'should alias session to mapped user session' do
    test_path_and_url :session
    test_path_and_url :session, :new
  end

  test 'should alias password to mapped user password' do
    test_path_and_url :password
    test_path_and_url :password, :new
    test_path_and_url :password, :edit
  end

  test 'should alias confirmation to mapped user confirmation' do
    test_path_and_url :confirmation
    test_path_and_url :confirmation, :new
  end
end
