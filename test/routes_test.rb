require 'test/test_helper'

class MapRoutingTest < ActionController::TestCase

  test 'map devise user session' do
    assert_recognizes({:controller => 'sessions', :action => 'new'}, 'users/session/new')
  end

  test 'map devise user confirmation' do
    assert_recognizes({:controller => 'confirmations', :action => 'new'}, 'users/confirmation/new')
  end

  test 'map devise user password' do
    assert_recognizes({:controller => 'passwords', :action => 'new'}, 'users/password/new')
  end

  test 'map devise admin session with :as option' do
    assert_recognizes({:controller => 'sessions', :action => 'new'}, 'admin_area/session/new')
  end

  test 'map devise admin confirmation with :as option' do
    assert_recognizes({:controller => 'confirmations', :action => 'new'}, 'admin_area/confirmation/new')
  end

  test 'map devise admin password with :as option' do
    assert_raise ActionController::RoutingError do
      assert_recognizes({:controller => 'passwords', :action => 'new'}, 'admin_area/password/new')
    end
  end

end
