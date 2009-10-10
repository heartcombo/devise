require 'test_helper'

class SessionRoutingTest < ActionController::TestCase

  test 'new session route' do
    assert_recognizes({:controller => 'sessions', :action => 'new'}, 'users/session/new')
  end

  test 'create session route' do
    assert_recognizes({:controller => 'sessions', :action => 'create'}, {:path => 'users/session', :method => :post})
  end

  test 'destroy session route' do
    assert_recognizes({:controller => 'sessions', :action => 'destroy'}, {:path => 'users/session', :method => :delete})
  end

  test 'translate session route' do
    translated_route(:session => 'sessao') do
      assert_recognizes({:controller => 'sessions', :action => 'new'}, 'users/sessao/new')
    end
  end
end
