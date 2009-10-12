require 'test/test_helper'

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

  test 'new admin password route' do
    assert_recognizes({:controller => 'passwords', :action => 'new'}, 'admin_area/password/new')
  end

  test 'create admin password route' do
    assert_recognizes({:controller => 'passwords', :action => 'create'}, {:path => 'admin_area/password', :method => :post})
  end

  test 'edit admin password route' do
    assert_recognizes({:controller => 'passwords', :action => 'edit'}, 'admin_area/password/edit')
  end

  test 'update admin password route' do
    assert_recognizes({:controller => 'passwords', :action => 'update'}, {:path => 'admin_area/password', :method => :put})
  end
end
