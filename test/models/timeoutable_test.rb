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

  test 'should accept timeout_in proc and provide user as argument' do
    user = new_user

    timeout_in = proc do |obj|
      assert_equal user, obj
      10.minutes
    end

    swap Devise, :timeout_in => timeout_in do
      assert user.timedout?(12.minutes.ago)
      assert_not user.timedout?(8.minutes.ago)
    end
  end

  test 'should not be expired when timeout_in proc returns nil' do
    swap Devise, :timeout_in => proc { nil } do
      assert_not new_user.timedout?(10.hours.ago)
    end
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
