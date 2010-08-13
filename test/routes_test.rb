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

  test 'map new user unlock' do
    assert_recognizes({:controller => 'unlocks', :action => 'new'}, 'users/unlock/new')
  end

  test 'map create user unlock' do
    assert_recognizes({:controller => 'unlocks', :action => 'create'}, {:path => 'users/unlock', :method => :post})
  end

  test 'map show user unlock' do
    assert_recognizes({:controller => 'unlocks', :action => 'show'}, {:path => 'users/unlock', :method => :get})
  end

  test 'map new user registration' do
    assert_recognizes({:controller => 'registrations', :action => 'new'}, 'users/sign_up')
  end

  test 'map create user registration' do
    assert_recognizes({:controller => 'registrations', :action => 'create'}, {:path => 'users', :method => :post})
  end

  test 'map edit user registration' do
    assert_recognizes({:controller => 'registrations', :action => 'edit'}, {:path => 'users/edit', :method => :get})
  end

  test 'map update user registration' do
    assert_recognizes({:controller => 'registrations', :action => 'update'}, {:path => 'users', :method => :put})
  end

  test 'map destroy user registration' do
    assert_recognizes({:controller => 'registrations', :action => 'destroy'}, {:path => 'users', :method => :delete})
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
    assert_recognizes({:controller => 'sessions', :action => 'new', :locale => 'en', :extra => 'value'}, '/en/accounts/login')
  end

  test 'map account with custom path name for session sign out' do
    assert_recognizes({:controller => 'sessions', :action => 'destroy', :locale => 'en', :extra => 'value'}, '/en/accounts/logout')
  end

  test 'map account with custom path name for password' do
    assert_recognizes({:controller => 'passwords', :action => 'new', :locale => 'en', :extra => 'value'}, '/en/accounts/secret/new')
  end

  test 'map account with custom path name for confirmation' do
    assert_recognizes({:controller => 'confirmations', :action => 'new', :locale => 'en', :extra => 'value'}, '/en/accounts/verification/new')
  end

  test 'map account with custom path name for unlock' do
    assert_recognizes({:controller => 'unlocks', :action => 'new', :locale => 'en', :extra => 'value'}, '/en/accounts/unblock/new')
  end

  test 'map account with custom path name for registration' do
    assert_recognizes({:controller => 'registrations', :action => 'new', :locale => 'en', :extra => 'value'}, '/en/accounts/register')
  end

  test 'map deletes with :sign_out_via option' do
    assert_recognizes({:controller => 'sessions', :action => 'destroy'}, {:path => '/sign_out_via_deletes/sign_out', :method => :delete})
    assert_raise ActionController::MethodNotAllowed do
      assert_recognizes({:controller => 'sessions', :action => 'destroy'}, {:path => '/sign_out_via_deletes/sign_out', :method => :get})
    end
  end

  test 'map posts with :sign_out_via option' do
    assert_recognizes({:controller => 'sessions', :action => 'destroy'}, {:path => '/sign_out_via_posts/sign_out', :method => :post})
    assert_raise ActionController::MethodNotAllowed do
      assert_recognizes({:controller => 'sessions', :action => 'destroy'}, {:path => '/sign_out_via_posts/sign_out', :method => :get})
    end
  end

  test 'map any methods with :sign_out_via option' do
    assert_recognizes({:controller => 'sessions', :action => 'destroy'}, {:path => '/sign_out_via_anymethods/sign_out', :method => :get})
    assert_recognizes({:controller => 'sessions', :action => 'destroy'}, {:path => '/sign_out_via_anymethods/sign_out', :method => :post})
    assert_recognizes({:controller => 'sessions', :action => 'destroy'}, {:path => '/sign_out_via_anymethods/sign_out', :method => :delete})
    assert_recognizes({:controller => 'sessions', :action => 'destroy'}, {:path => '/sign_out_via_anymethods/sign_out', :method => :put})
  end
end
