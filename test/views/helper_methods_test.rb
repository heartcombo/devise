# frozen_string_literal: true
require 'test_helper'

module ActionView
  include Devise::Views::Helpers
end

class ViewsHelperMethodsTest < Devise::IntegrationTest

  test 'Action View includes Devise::Views::Helpers' do
    assert_includes  ActionView.ancestors, Devise::Views::Helpers
  end

  test 'ActionView defines signed_in_user' do
    assert ActionView.instance_methods.include?(:signed_in_user)
  end

  test 'ActionView defines signed_out_user' do
    assert ActionView.instance_methods.include?(:signed_out_user)
  end

end
