require 'test_helper'

class RememberableTest < ActiveSupport::TestCase
  def resource_class
    User
  end

  def create_resource
    create_user
  end

  test 'remember_me should not generate a new token if using salt' do
    user = create_user
    user.expects(:valid?).never
    user.remember_me!
  end

  test 'forget_me should not clear remember token if using salt' do
    user = create_user
    user.remember_me!
    user.expects(:valid?).never
    user.forget_me!
  end

  test 'serialize into cookie' do
    user = create_user
    user.remember_me!
    assert_equal [user.to_key, user.authenticatable_salt], User.serialize_into_cookie(user)
  end

  test 'serialize from cookie' do
    user = create_user
    user.remember_me!
    assert_equal user, User.serialize_from_cookie(user.to_key, user.authenticatable_salt)
  end

  test 'raises a RuntimeError if authenticatable_salt is nil' do
    user = User.new
    user.encrypted_password = nil
    assert_raise RuntimeError do
      user.rememberable_value
    end
  end

  test 'should respond to remember_me attribute' do
    assert resource_class.new.respond_to?(:remember_me)
    assert resource_class.new.respond_to?(:remember_me=)
  end

  test 'forget_me should clear remember_created_at' do
    resource = create_resource
    resource.remember_me!
    assert_not resource.remember_created_at.nil?
    resource.forget_me!
    assert resource.remember_created_at.nil?
  end

  test 'forget_me should not try to update resource if it has been destroyed' do
    resource = create_resource
    resource.expects(:remember_created_at).never
    resource.expects(:save).never

    resource.destroy
    resource.forget_me!
  end

  test 'remember is expired if not created at timestamp is set' do
    assert create_resource.remember_expired?
  end

  test 'serialize should return nil if no resource is found' do
    assert_nil resource_class.serialize_from_cookie([0], "123")
  end

  test 'remember me return nil if is a valid resource with invalid token' do
    resource = create_resource
    assert_nil resource_class.serialize_from_cookie([resource.id], "123")
  end

  test 'remember for should fallback to devise remember for default configuration' do
    swap Devise, :remember_for => 1.day do
      resource = create_resource
      resource.remember_me!
      assert_not resource.remember_expired?
    end
  end

  test 'remember expires at should sum date of creation with remember for configuration' do
    swap Devise, :remember_for => 3.days do
      resource = create_resource
      resource.remember_me!
      assert_equal 3.days.from_now.to_date, resource.remember_expires_at.to_date

      Devise.remember_for = 5.days
      assert_equal 5.days.from_now.to_date, resource.remember_expires_at.to_date
    end
  end

  test 'remember should be expired if remember_for is zero' do
    swap Devise, :remember_for => 0.days do
      Devise.remember_for = 0.days
      resource = create_resource
      resource.remember_me!
      assert resource.remember_expired?
    end
  end

  test 'remember should be expired if it was created before limit time' do
    swap Devise, :remember_for => 1.day do
      resource = create_resource
      resource.remember_me!
      resource.remember_created_at = 2.days.ago
      resource.save
      assert resource.remember_expired?
    end
  end

  test 'remember should not be expired if it was created within the limit time' do
    swap Devise, :remember_for => 30.days do
      resource = create_resource
      resource.remember_me!
      resource.remember_created_at = (30.days.ago + 2.minutes)
      resource.save
      assert_not resource.remember_expired?
    end
  end

  test 'if extend_remember_period is false, remember_me! should generate a new timestamp if expired' do
    swap Devise, :remember_for => 5.minutes do
      resource = create_resource
      resource.remember_me!(false)
      assert resource.remember_created_at

      resource.remember_created_at = old = 10.minutes.ago
      resource.save

      resource.remember_me!(false)
      assert_not_equal old.to_i, resource.remember_created_at.to_i
    end
  end

  test 'if extend_remember_period is false, remember_me! should not generate a new timestamp' do
    swap Devise, :remember_for => 1.year do
      resource = create_resource
      resource.remember_me!(false)
      assert resource.remember_created_at

      resource.remember_created_at = old = 10.minutes.ago.utc
      resource.save

      resource.remember_me!(false)
      assert_equal old.to_i, resource.remember_created_at.to_i
    end
  end

  test 'if extend_remember_period is true, remember_me! should always generate a new timestamp' do
    swap Devise, :remember_for => 1.year do
      resource = create_resource
      resource.remember_me!(true)
      assert resource.remember_created_at

      resource.remember_created_at = old = 10.minutes.ago
      resource.save

      resource.remember_me!(true)
      assert_not_equal old, resource.remember_created_at
    end
  end

  test 'should have the required_fields array' do
    assert_same_content Devise::Models::Rememberable.required_fields(User), [
      :remember_created_at
    ]
  end
end
