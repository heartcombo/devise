require 'test/test_helper'

class SessionRoutingTest < ActionController::TestCase

  test 'new user session route' do
    assert_recognizes({:controller => 'sessions', :action => 'new'}, 'users/session/new')
  end

  test 'create user session route' do
    assert_recognizes({:controller => 'sessions', :action => 'create'}, {:path => 'users/session', :method => :post})
  end

  test 'destroy user session route' do
    assert_recognizes({:controller => 'sessions', :action => 'destroy'}, {:path => 'users/session', :method => :delete})
  end

  test 'new admin session route' do
    assert_recognizes({:controller => 'sessions', :action => 'new'}, 'admin_area/session/new')
  end

  test 'create admin session route' do
    assert_recognizes({:controller => 'sessions', :action => 'create'}, {:path => 'admin_area/session', :method => :post})
  end

  test 'destroy admin session route' do
    assert_recognizes({:controller => 'sessions', :action => 'destroy'}, {:path => 'admin_area/session', :method => :delete})
  end
end
