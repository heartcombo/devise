require 'test_helper'

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

  test 'new account session route' do
    assert_recognizes({:controller => 'confirmations', :action => 'new'}, 'conta/confirmation/new')
  end

  test 'create account confirmation route' do
    assert_recognizes({:controller => 'confirmations', :action => 'create'}, {:path => 'conta/confirmation', :method => :post})
  end

  test 'show account confirmation route' do
    assert_recognizes({:controller => 'confirmations', :action => 'show'}, 'conta/confirmation')
  end
end
