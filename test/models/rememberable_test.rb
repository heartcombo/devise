require 'test_helper'

class RememberableTest < ActiveSupport::TestCase
  test 'should respond to remember_me attribute' do
    user = new_user
    assert user.respond_to?(:remember_me)
  end

  test 'remember_me should generate a new token and save the record without validating' do
    user = create_user
    user.expects(:valid?).never
    token = user.remember_token
    user.remember_me!
    assert_not_equal token, user.remember_token
    assert_not user.changed?
  end

  test 'forget_me should clear remember token and save the record without validating' do
    user = create_user
    user.remember_me!
    assert_not user.remember_token.nil?
    user.expects(:valid?).never
    user.forget_me!
    assert user.remember_token.nil?
    assert_not user.changed?
  end

  test 'forget_me should clear remember_created_at' do
    user = create_user
    user.remember_me!
    assert_not user.remember_created_at.nil?
    user.forget_me!
    assert user.remember_created_at.nil?
  end

  test 'forget should do nothing if no remember token exists' do
    user = create_user
    user.expects(:save).never
    user.forget_me!
  end

  test 'serialize into cookie' do
    user = create_user
    user.remember_me!
    assert_equal [user.id, user.remember_token], User.serialize_into_cookie(user)
  end

  test 'serialize from cookie' do
    user = create_user
    user.remember_me!
    assert_equal user, User.serialize_from_cookie(user.id, user.remember_token)
  end

  test 'serialize should return nil if no user is found' do
    assert_nil User.serialize_from_cookie(0, "123")
  end

  test 'remember me return nil if is a valid user with invalid token' do
    user = create_user
    assert_nil User.serialize_from_cookie(user.id, "123")
  end

  test 'remember for should fallback to devise remember for default configuration' do
    swap Devise, :remember_for => 1.day do
      user = create_user
      user.remember_me!
      assert_not user.remember_expired?
    end
  end

  test 'remember expires at should sum date of creation with remember for configuration' do
    swap Devise, :remember_for => 3.days do
      user = create_user
      user.remember_me!
      assert_equal 3.days.from_now.to_date, user.remember_expires_at.to_date

      Devise.remember_for = 5.days
      assert_equal 5.days.from_now.to_date, user.remember_expires_at.to_date
    end
  end

  test 'remember should be expired if remember_for is zero' do
    swap Devise, :remember_for => 0.days do
      Devise.remember_for = 0.days
      user = create_user
      user.remember_me!
      assert user.remember_expired?
    end
  end

  test 'remember should be expired if it was created before limit time' do
    swap Devise, :remember_for => 1.day do
      user = create_user
      user.remember_me!
      user.remember_created_at = 2.days.ago
      user.save
      assert user.remember_expired?
    end
  end

  test 'remember should not be expired if it was created whitin the limit time' do
    swap Devise, :remember_for => 30.days do
      user = create_user
      user.remember_me!
      user.remember_created_at = (30.days.ago + 2.minutes)
      user.save
      assert_not user.remember_expired?
    end
  end

  test 'if extend_remember_period is false, remember_me! should generate a new timestamp if expired' do
    swap Devise, :remember_for => 5.minutes do
      user = create_user
      user.remember_me!(false)
      assert user.remember_created_at

      user.remember_created_at = old = 10.minutes.ago
      user.save

      user.remember_me!(false)
      assert_not_equal old.to_i, user.remember_created_at.to_i
    end
  end

  test 'if extend_remember_period is false, remember_me! should not generate a new timestamp' do
    swap Devise, :remember_for => 1.year do
      user = create_user
      user.remember_me!(false)
      assert user.remember_created_at

      user.remember_created_at = old = 10.minutes.ago.utc
      user.save

      user.remember_me!(false)
      assert_equal old.to_i, user.remember_created_at.to_i
    end
  end

  test 'if extend_remember_period is true, remember_me! should always generate a new timestamp' do
    swap Devise, :remember_for => 1.year do
      user = create_user
      user.remember_me!(true)
      assert user.remember_created_at

      user.remember_created_at = old = 10.minutes.ago
      user.save

      user.remember_me!(true)
      assert_not_equal old, user.remember_created_at
    end
  end

  test 'if remember_across_browsers is true, remember_me! should create a new token if no token exists' do
    swap Devise, :remember_across_browsers => true, :remember_for => 1.year do
      user = create_user
      assert_equal nil, user.remember_token
      user.remember_me!
      assert_not_equal nil, user.remember_token
    end
  end

  test 'if remember_across_browsers is true, remember_me! should create a new token if a token exists but has expired' do
    swap Devise, :remember_across_browsers => true, :remember_for => 1.day do
      user = create_user
      user.remember_me!
      user.remember_created_at = 2.days.ago
      user.save
      token = user.remember_token
      user.remember_me!
      assert_not_equal token, user.remember_token
    end
  end

  test 'if remember_across_browsers is true, remember_me! should not create a new token if a token exists and has not expired' do
    swap Devise, :remember_across_browsers => true, :remember_for => 2.days do
      user = create_user
      user.remember_me!
      user.remember_created_at = 1.day.ago
      user.save
      token = user.remember_token
      user.remember_me!
      assert_equal token, user.remember_token
    end
  end

  test 'if remember_across_browsers is false, remember_me! should create a new token if no token exists' do
    swap Devise, :remember_across_browsers => false do
      user = create_user
      assert_equal nil, user.remember_token
      user.remember_me!
      assert_not_equal nil, user.remember_token
    end
  end

  test 'if remember_across_browsers is false, remember_me! should create a new token if a token exists but has expired' do
    swap Devise, :remember_across_browsers => false, :remember_for => 1.day do
      user = create_user
      user.remember_me!
      user.remember_created_at = 2.days.ago
      user.save
      token = user.remember_token
      user.remember_me!
      assert_not_equal token, user.remember_token
    end
  end

  test 'if remember_across_browsers is false, remember_me! should create a new token if a token exists and has not expired' do
    swap Devise, :remember_across_browsers => false, :remember_for => 2.days do
      user = create_user
      user.remember_me!
      user.remember_created_at = 1.day.ago
      user.save
      token = user.remember_token
      user.remember_me!
      assert_not_equal token, user.remember_token
    end
  end
end
