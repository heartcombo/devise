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

  test 'should use timeout_in method' do
    user = new_user
    user.instance_eval { def timeout_in; 10.minutes end }

    assert user.timedout?(12.minutes.ago)
    assert_not user.timedout?(8.minutes.ago)
  end

  test 'should not be expired when timeout_in method returns nil' do
    user = new_user
    user.instance_eval { def timeout_in; nil end }
    assert_not user.timedout?(10.hours.ago)
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

  test 'required_fields should contain the fields that Devise uses' do
    assert_same_content Devise::Models::Timeoutable.required_fields(User), []
  end
end
