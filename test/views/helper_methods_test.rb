# frozen_string_literal: true
require 'test_helper'

module ActionView
  include Devise::Views::Helpers
end

class ViewsHelperMethodsTest < Devise::IntegrationTest

  # Figure out which Rails Test class/module to inherit from to properly test
  # setup test to run through devise initialization

  # Assert that Devise::Views::Helpers is a member of the Devise @@helpers class variable
  # because that is how the helper methods get generated
  # ^ maybe
  #
  # Add module to ActionController & ActionView; Figure out wether extend or include is the move

  test 'ActionView defines signed_in_user' do
    p ActionView.instance_methods
    assert ActionView.instance_methods.include?(:signed_in_user)
  end

  test 'ActionView defines signed_out_user' do
    assert ActionView.instance_methods.include?(:signed_out_user)
  end

end
