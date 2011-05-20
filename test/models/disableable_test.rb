require 'test_helper'

class DisableableTest < ActiveSupport::TestCase
  test 'accounts are not disabled by default' do
    user = new_user
    assert user.confirm!
    assert_not user.disabled?
    assert user.active_for_authentication?
  end

  test 'accounts can be disabled' do
    user = new_user
    assert user.confirm!
    user.disabled = true
    assert_not user.active_for_authentication?
    assert_equal :disabled, user.inactive_message
  end
end
