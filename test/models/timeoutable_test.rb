require 'test/test_helper'

class TimeoutableTest < ActiveSupport::TestCase

  test 'should be expired' do
    assert new_user.timeout?(31.minutes.ago)
  end

  test 'should not be expired' do
    assert_not new_user.timeout?(29.minutes.ago)
  end

  test 'should not be expired when params is nil' do
    assert_not new_user.timeout?(nil)
  end

  test 'fallback to Devise config option' do
    swap Devise, :timeout_in => 1.minute do
      user = new_user
      assert user.timeout?(2.minutes.ago)
      assert_not user.timeout?(30.seconds.ago)

      Devise.timeout_in = 5.minutes
      assert_not user.timeout?(2.minutes.ago)
      assert user.timeout?(6.minutes.ago)
    end
  end
end
