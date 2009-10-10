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

  test 'map devise account session with :as option' do
    assert_recognizes({:controller => 'sessions', :action => 'new'}, 'conta/session/new')
  end

  test 'map devise account confirmation with :as option' do
    assert_recognizes({:controller => 'confirmations', :action => 'new'}, 'conta/confirmation/new')
  end

  test 'map devise account password with :as option' do
    assert_recognizes({:controller => 'passwords', :action => 'new'}, 'conta/password/new')
  end
end
