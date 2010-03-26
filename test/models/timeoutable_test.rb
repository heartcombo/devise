require 'test_helper'

class TimeoutableTest < ActiveSupport::TestCase

  test 'should be expired' do
    assert new_user.timedout?(31.minutes.ago)
  end

  test 'should not be expired' do
    assert_not new_user.timedout?(29.minutes.ago)
  end

  test 'should not be expired when params is nil' do
    assert_not new_user.timedout?(nil)
  end

  test 'fallback to Devise config option' do
    swap Devise, :timeout_in => 1.minute do
      user = new_user
      assert user.timedout?(2.minutes.ago)
      assert_not user.timedout?(30.seconds.ago)

      Devise.timeout_in = 5.minutes
      assert_not user.timedout?(2.minutes.ago)
      assert user.timedout?(6.minutes.ago)
    end
  end
end
