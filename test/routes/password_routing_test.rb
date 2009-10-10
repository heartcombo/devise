require 'test_helper'

class PasswordRoutingTest < ActionController::TestCase

  test 'new password route' do
    assert_routing('users/password/new', :controller => 'passwords', :action => 'new')
  end

  test 'create password route' do
    assert_routing({:path => 'users/password', :method => :post}, {:controller => 'passwords', :action => 'create'})
  end

  test 'edit password route' do
    assert_routing('users/password/edit', :controller => 'passwords', :action => 'edit')
  end

  test 'update password route' do
    assert_routing({:path => 'users/password', :method => :put}, {:controller => 'passwords', :action => 'update'})
  end

  test 'translated password route' do
    translated_route(:password => 'senha') do
      assert_routing('users/senha/new', :controller => 'passwords', :action => 'new')
    end
  end
end
