require 'test_helper'

class ConfirmationRoutingTest < ActionController::TestCase

  test 'new session route' do
    assert_routing('/confirmation/new', :controller => 'confirmations', :action => 'new')
  end

  test 'create confirmation route' do
    assert_routing({:path => '/confirmation', :method => :post}, {:controller => 'confirmations', :action => 'create'})
  end

  test 'show confirmation route' do
    assert_routing('/confirmation', :controller => 'confirmations', :action => 'show')
  end

  test 'translated confirmation route' do
    translated_route(:confirmation => 'confirmacao') do
      assert_routing('/confirmacao/new', :controller => 'confirmations', :action => 'new')
    end
  end
end
