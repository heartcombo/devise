require 'test/test_helper'

class MapRoutingTest < ActionController::TestCase

  test 'map new user session' do
    assert_recognizes({:controller => 'sessions', :action => 'new'}, {:path => 'users/sign_in', :method => :get})
  end

  test 'map create user session' do
    assert_recognizes({:controller => 'sessions', :action => 'create'}, {:path => 'users/sign_in', :method => :post})
  end

  test 'map destroy user session' do
    assert_recognizes({:controller => 'sessions', :action => 'destroy'}, {:path => 'users/sign_out', :method => :get})
  end

  test 'map new user confirmation' do
    assert_recognizes({:controller => 'confirmations', :action => 'new'}, 'users/confirmation/new')
  end

  test 'map create user confirmation' do
    assert_recognizes({:controller => 'confirmations', :action => 'create'}, {:path => 'users/confirmation', :method => :post})
  end

  test 'map show user confirmation' do
    assert_recognizes({:controller => 'confirmations', :action => 'show'}, {:path => 'users/confirmation', :method => :get})
  end

  test 'map new user password' do
    assert_recognizes({:controller => 'passwords', :action => 'new'}, 'users/password/new')
  end

  test 'map create user password' do
    assert_recognizes({:controller => 'passwords', :action => 'create'}, {:path => 'users/password', :method => :post})
  end

  test 'map edit user password' do
    assert_recognizes({:controller => 'passwords', :action => 'edit'}, 'users/password/edit')
  end

  test 'map update user password' do
    assert_recognizes({:controller => 'passwords', :action => 'update'}, {:path => 'users/password', :method => :put})
  end

  test 'map admin session with :as option' do
    assert_recognizes({:controller => 'sessions', :action => 'new'}, {:path => 'admin_area/sign_in', :method => :get})
  end

  test 'does not map admin confirmation' do
    assert_raise ActionController::RoutingError do
      assert_recognizes({:controller => 'confirmations', :action => 'new'}, 'admin_area/confirmation/new')
    end
  end

  test 'map account with custom path name for session sign in' do
    assert_recognizes({:controller => 'sessions', :action => 'new'}, 'account/login')
  end

  test 'map account with custom path name for session sign out' do
    assert_recognizes({:controller => 'sessions', :action => 'destroy'}, 'account/logout')
  end

  test 'map account with custom path name for password' do
    assert_recognizes({:controller => 'passwords', :action => 'new'}, 'account/secret/new')
  end

  test 'map account with custom path name for confirmation' do
    assert_recognizes({:controller => 'confirmations', :action => 'new'}, 'account/verification/new')
  end

  test 'map organizer with custom singular name' do
    assert_recognizes({:controller => 'passwords', :action => 'new'}, 'organizers/password/new')
  end

end
