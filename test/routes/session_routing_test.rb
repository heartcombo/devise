require 'test_helper'

class SessionRoutingTest < ActionController::TestCase

  test 'new session route' do
    assert_routing('users/session/new', :controller => 'sessions', :action => 'new')
  end

  test 'create session route' do
    assert_routing({:path => 'users/session', :method => :post}, {:controller => 'sessions', :action => 'create'})
  end

  test 'destroy session route' do
    assert_routing({:path => 'users/session', :method => :delete}, {:controller => 'sessions', :action => 'destroy'})
  end

  test 'translate session route' do
    translated_route(:session => 'sessao') do
      assert_routing('users/sessao/new', :controller => 'sessions', :action => 'new')
    end
  end
end
