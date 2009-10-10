require 'test_helper'

class ConfirmationRoutingTest < ActionController::TestCase

  test 'new session route' do
    assert_routing('users/confirmation/new', :controller => 'confirmations', :action => 'new')
  end

  test 'create confirmation route' do
    assert_routing({:path => 'users/confirmation', :method => :post}, {:controller => 'confirmations', :action => 'create'})
  end

  test 'show confirmation route' do
    assert_routing('users/confirmation', :controller => 'confirmations', :action => 'show')
  end

  test 'translated confirmation route' do
    translated_route(:confirmation => 'confirmacao') do
      assert_routing('users/confirmacao/new', :controller => 'confirmations', :action => 'new')
    end
  end
end
