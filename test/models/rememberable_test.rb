require 'test/test_helper'

class RememberableTest < ActiveSupport::TestCase

  test 'should respond to remember_me attribute' do
    user = new_user
    assert user.respond_to?(:remember_me)
  end

  test 'should have remember_me accessible' do
    assert field_accessible?(:remember_me)
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
    assert_not_nil user.remember_token
    user.expects(:valid?).never
    user.forget_me!
    assert_nil user.remember_token
    assert_not user.changed?
  end

  test 'forget should do nothing if no remember token exists' do
    user = create_user
    user.expects(:save).never
    user.forget_me!
  end

  test 'valid remember token' do
    user = create_user
    assert_not user.valid_remember_token?(user.remember_token)
    user.remember_me!
    assert user.valid_remember_token?(user.remember_token)
    user.forget_me!
    assert_not user.valid_remember_token?(user.remember_token)
  end

  test 'serialize into cookie' do
    user = create_user
    user.remember_me!
    assert_equal "#{user.id}::#{user.remember_token}", User.serialize_into_cookie(user)
  end

  test 'serialize from cookie' do
    user = create_user
    user.remember_me!
    assert_equal user, User.serialize_from_cookie("#{user.id}::#{user.remember_token}")
  end

  test 'serialize should return nil if no user is found' do
    assert_nil User.serialize_from_cookie('0::123')
  end

  test 'remember me return nil if is a valid user with invalid token' do
    user = create_user
    assert_nil User.serialize_from_cookie("#{user.id}::#{user.remember_token}123")
  end
end
