require 'test_helper'

class PasswordRoutingTest < ActionController::TestCase

  test 'new password route' do
    assert_recognizes({:controller => 'passwords', :action => 'new'}, 'users/password/new')
  end

  test 'create password route' do
    assert_recognizes({:controller => 'passwords', :action => 'create'}, {:path => 'users/password', :method => :post})
  end

  test 'edit password route' do
    assert_recognizes({:controller => 'passwords', :action => 'edit'}, 'users/password/edit')
  end

  test 'update password route' do
    assert_recognizes({:controller => 'passwords', :action => 'update'}, {:path => 'users/password', :method => :put})
  end

  test 'translated password route' do
    translated_route(:password => 'senha') do
      assert_recognizes({:controller => 'passwords', :action => 'new'}, 'users/senha/new')
    end
  end
end
