require 'test_helper'

class RememberableTest < ActiveSupport::TestCase
  test 'should respond to remember_me attribute' do
    assert Admin.new.respond_to?(:remember_me)
    assert Admin.new.respond_to?(:remember_me=)
  end

  test 'remember_me should generate a new token and save the record without validating' do
    admin = create_admin
    admin.expects(:valid?).never
    token = admin.remember_token
    admin.remember_me!
    assert_not_equal token, admin.remember_token
    assert_not admin.changed?
  end

  test 'forget_me should clear remember token and save the record without validating' do
    admin = create_admin
    admin.remember_me!
    assert_not admin.remember_token.nil?
    admin.expects(:valid?).never
    admin.forget_me!
    assert admin.remember_token.nil?
    assert_not admin.changed?
  end

  test 'forget_me should clear remember_created_at' do
    admin = create_admin
    admin.remember_me!
    assert_not admin.remember_created_at.nil?
    admin.forget_me!
    assert admin.remember_created_at.nil?
  end

  test 'forget should do nothing if no remember token exists' do
    admin = create_admin
    admin.expects(:save).never
    admin.forget_me!
  end

  test 'serialize into cookie' do
    admin = create_admin
    admin.remember_me!
    assert_equal [admin.id, admin.remember_token], Admin.serialize_into_cookie(admin)
  end

  test 'serialize from cookie' do
    admin = create_admin
    admin.remember_me!
    assert_equal admin, Admin.serialize_from_cookie(admin.id, admin.remember_token)
  end

  test 'serialize should return nil if no admin is found' do
    assert_nil Admin.serialize_from_cookie(0, "123")
  end

  test 'remember me return nil if is a valid admin with invalid token' do
    admin = create_admin
    assert_nil Admin.serialize_from_cookie(admin.id, "123")
  end

  test 'remember for should fallback to devise remember for default configuration' do
    swap Devise, :remember_for => 1.day do
      admin = create_admin
      admin.remember_me!
      assert_not admin.remember_expired?
    end
  end

  test 'remember expires at should sum date of creation with remember for configuration' do
    swap Devise, :remember_for => 3.days do
      admin = create_admin
      admin.remember_me!
      assert_equal 3.days.from_now.to_date, admin.remember_expires_at.to_date

      Devise.remember_for = 5.days
      assert_equal 5.days.from_now.to_date, admin.remember_expires_at.to_date
    end
  end

  test 'remember should be expired if remember_for is zero' do
    swap Devise, :remember_for => 0.days do
      Devise.remember_for = 0.days
      admin = create_admin
      admin.remember_me!
      assert admin.remember_expired?
    end
  end

  test 'remember should be expired if it was created before limit time' do
    swap Devise, :remember_for => 1.day do
      admin = create_admin
      admin.remember_me!
      admin.remember_created_at = 2.days.ago
      admin.save
      assert admin.remember_expired?
    end
  end

  test 'remember should not be expired if it was created whitin the limit time' do
    swap Devise, :remember_for => 30.days do
      admin = create_admin
      admin.remember_me!
      admin.remember_created_at = (30.days.ago + 2.minutes)
      admin.save
      assert_not admin.remember_expired?
    end
  end

  test 'if extend_remember_period is false, remember_me! should generate a new timestamp if expired' do
    swap Devise, :remember_for => 5.minutes do
      admin = create_admin
      admin.remember_me!(false)
      assert admin.remember_created_at

      admin.remember_created_at = old = 10.minutes.ago
      admin.save

      admin.remember_me!(false)
      assert_not_equal old.to_i, admin.remember_created_at.to_i
    end
  end

  test 'if extend_remember_period is false, remember_me! should not generate a new timestamp' do
    swap Devise, :remember_for => 1.year do
      admin = create_admin
      admin.remember_me!(false)
      assert admin.remember_created_at

      admin.remember_created_at = old = 10.minutes.ago.utc
      admin.save

      admin.remember_me!(false)
      assert_equal old.to_i, admin.remember_created_at.to_i
    end
  end

  test 'if extend_remember_period is true, remember_me! should always generate a new timestamp' do
    swap Devise, :remember_for => 1.year do
      admin = create_admin
      admin.remember_me!(true)
      assert admin.remember_created_at

      admin.remember_created_at = old = 10.minutes.ago
      admin.save

      admin.remember_me!(true)
      assert_not_equal old, admin.remember_created_at
    end
  end

  test 'if remember_across_browsers is true, remember_me! should create a new token if no token exists' do
    swap Devise, :remember_across_browsers => true, :remember_for => 1.year do
      admin = create_admin
      assert_equal nil, admin.remember_token
      admin.remember_me!
      assert_not_equal nil, admin.remember_token
    end
  end

  test 'if remember_across_browsers is true, remember_me! should create a new token if a token exists but has expired' do
    swap Devise, :remember_across_browsers => true, :remember_for => 1.day do
      admin = create_admin
      admin.remember_me!
      admin.remember_created_at = 2.days.ago
      admin.save
      token = admin.remember_token
      admin.remember_me!
      assert_not_equal token, admin.remember_token
    end
  end

  test 'if remember_across_browsers is true, remember_me! should not create a new token if a token exists and has not expired' do
    swap Devise, :remember_across_browsers => true, :remember_for => 2.days do
      admin = create_admin
      admin.remember_me!
      admin.remember_created_at = 1.day.ago
      admin.save
      token = admin.remember_token
      admin.remember_me!
      assert_equal token, admin.remember_token
    end
  end

  test 'if remember_across_browsers is false, remember_me! should create a new token if no token exists' do
    swap Devise, :remember_across_browsers => false do
      admin = create_admin
      assert_equal nil, admin.remember_token
      admin.remember_me!
      assert_not_equal nil, admin.remember_token
    end
  end

  test 'if remember_across_browsers is false, remember_me! should create a new token if a token exists but has expired' do
    swap Devise, :remember_across_browsers => false, :remember_for => 1.day do
      admin = create_admin
      admin.remember_me!
      admin.remember_created_at = 2.days.ago
      admin.save
      token = admin.remember_token
      admin.remember_me!
      assert_not_equal token, admin.remember_token
    end
  end

  test 'if remember_across_browsers is false, remember_me! should create a new token if a token exists and has not expired' do
    swap Devise, :remember_across_browsers => false, :remember_for => 2.days do
      admin = create_admin
      admin.remember_me!
      admin.remember_created_at = 1.day.ago
      admin.save
      token = admin.remember_token
      admin.remember_me!
      assert_not_equal token, admin.remember_token
    end
  end
end
