require 'test_helper'

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

  test 'translate session route' do
    translated_route(:session => 'sessao') do
      assert_recognizes({:controller => 'sessions', :action => 'new'}, 'users/sessao/new')
    end
  end

  test 'new account session route' do
    assert_recognizes({:controller => 'sessions', :action => 'new'}, 'conta/session/new')
  end

  test 'create account session route' do
    assert_recognizes({:controller => 'sessions', :action => 'create'}, {:path => 'conta/session', :method => :post})
  end

  test 'destroy account session route' do
    assert_recognizes({:controller => 'sessions', :action => 'destroy'}, {:path => 'conta/session', :method => :delete})
  end
end
