# frozen_string_literal: true

require 'test_helper'

class Rails7ApiModeTest < Devise::ControllerTestCase
  tests Devise::SessionsController
  include Devise::Test::ControllerHelpers

  test 'is injected into the Devise controllers' do
    assert @controller.is_a?(Devise::Controllers::Rails7ApiMode)
  end

  # note: disabling API mode in one test seems not feasible; the test harness breaks a little bit.
  #       we need to understand better how to cover API-only mode in devise to prevent future issues.
end
