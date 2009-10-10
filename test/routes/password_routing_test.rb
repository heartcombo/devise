require 'test_helper'

class PasswordRoutingTest < ActionController::TestCase

  test 'new user password route' do
    assert_recognizes({:controller => 'passwords', :action => 'new'}, 'users/password/new')
  end

  test 'create user password route' do
    assert_recognizes({:controller => 'passwords', :action => 'create'}, {:path => 'users/password', :method => :post})
  end

  test 'edit user password route' do
    assert_recognizes({:controller => 'passwords', :action => 'edit'}, 'users/password/edit')
  end

  test 'update user password route' do
    assert_recognizes({:controller => 'passwords', :action => 'update'}, {:path => 'users/password', :method => :put})
  end

  test 'translated password route' do
    translated_route(:password => 'senha') do
      assert_recognizes({:controller => 'passwords', :action => 'new'}, 'users/senha/new')
    end
  end

  test 'new account password route' do
    assert_recognizes({:controller => 'passwords', :action => 'new'}, 'conta/password/new')
  end

  test 'create account password route' do
    assert_recognizes({:controller => 'passwords', :action => 'create'}, {:path => 'conta/password', :method => :post})
  end

  test 'edit account password route' do
    assert_recognizes({:controller => 'passwords', :action => 'edit'}, 'conta/password/edit')
  end

  test 'update account password route' do
    assert_recognizes({:controller => 'passwords', :action => 'update'}, {:path => 'conta/password', :method => :put})
  end
end
