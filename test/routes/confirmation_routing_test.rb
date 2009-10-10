require 'test/test_helper'

class ConfirmationRoutingTest < ActionController::TestCase

  test 'new user session route' do
    assert_recognizes({:controller => 'confirmations', :action => 'new'}, 'users/confirmation/new')
  end

  test 'create user confirmation route' do
    assert_recognizes({:controller => 'confirmations', :action => 'create'}, {:path => 'users/confirmation', :method => :post})
  end

  test 'show user confirmation route' do
    assert_recognizes({:controller => 'confirmations', :action => 'show'}, 'users/confirmation')
  end

  test 'translated confirmation route' do
    translated_route(:confirmation => 'confirmacao') do
      assert_recognizes({:controller => 'confirmations', :action => 'new'}, 'users/confirmacao/new')
    end
  end

  test 'new admin session route' do
    assert_recognizes({:controller => 'confirmations', :action => 'new'}, 'admin_area/confirmation/new')
  end

  test 'create admin confirmation route' do
    assert_recognizes({:controller => 'confirmations', :action => 'create'}, {:path => 'admin_area/confirmation', :method => :post})
  end

  test 'show admin confirmation route' do
    assert_recognizes({:controller => 'confirmations', :action => 'show'}, 'admin_area/confirmation')
  end
end
