require 'test/test_helper'

class MapRoutingTest < ActionController::TestCase

  test 'map devise new user session' do
    assert_recognizes({:controller => 'sessions', :action => 'new'}, {:path => 'users/sign_in', :method => :get})
  end

  test 'map devise create user session' do
    assert_recognizes({:controller => 'sessions', :action => 'create'}, {:path => 'users/sign_in', :method => :post})
  end

  test 'map devise destroy user session' do
    assert_recognizes({:controller => 'sessions', :action => 'destroy'}, {:path => 'users/sign_out', :method => :get})
  end

  test 'map devise new user confirmation' do
    assert_recognizes({:controller => 'confirmations', :action => 'new'}, 'users/confirmation/new')
  end

  test 'map devise create user confirmation' do
    assert_recognizes({:controller => 'confirmations', :action => 'create'}, {:path => 'users/confirmation', :method => :post})
  end

  test 'map devise show user confirmation' do
    assert_recognizes({:controller => 'confirmations', :action => 'show'}, {:path => 'users/confirmation', :method => :get})
  end

  test 'map devise new user password' do
    assert_recognizes({:controller => 'passwords', :action => 'new'}, 'users/password/new')
  end

  test 'map devise create user password' do
    assert_recognizes({:controller => 'passwords', :action => 'create'}, {:path => 'users/password', :method => :post})
  end

  test 'map devise edit user password' do
    assert_recognizes({:controller => 'passwords', :action => 'edit'}, 'users/password/edit')
  end

  test 'map devise update user password' do
    assert_recognizes({:controller => 'passwords', :action => 'update'}, {:path => 'users/password', :method => :put})
  end

  test 'map devise admin session with :as option' do
    assert_recognizes({:controller => 'sessions', :action => 'new'}, {:path => 'admin_area/sign_in', :method => :get})
  end

  test 'does not map devise admin confirmation' do
    assert_raise ActionController::RoutingError do
      assert_recognizes({:controller => 'confirmations', :action => 'new'}, 'admin_area/confirmation/new')
    end
  end

end
