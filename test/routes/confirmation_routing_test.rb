require 'test_helper'

class ConfirmationRoutingTest < ActionController::TestCase

  test 'new session route' do
    assert_recognizes({:controller => 'confirmations', :action => 'new'}, 'users/confirmation/new')
  end

  test 'create confirmation route' do
    assert_recognizes({:controller => 'confirmations', :action => 'create'}, {:path => 'users/confirmation', :method => :post})
  end

  test 'show confirmation route' do
    assert_recognizes({:controller => 'confirmations', :action => 'show'}, 'users/confirmation')
  end

  test 'translated confirmation route' do
    translated_route(:confirmation => 'confirmacao') do
      assert_recognizes({:controller => 'confirmations', :action => 'new'}, 'users/confirmacao/new')
    end
  end
end
