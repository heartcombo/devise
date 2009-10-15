require 'test/test_helper'

class PerishableTest < ActiveSupport::TestCase

  test 'should not have perishable token accessible' do
    assert_not field_accessible?(:perishable_token)
  end

  test 'should generate perishable token after creating a record' do
    assert_nil new_user.perishable_token
    assert_not_nil create_user.perishable_token
  end

  test 'should reset perisable token each time' do
    user = new_user
    3.times do
      token = user.perishable_token
      user.reset_perishable_token
      assert_not_equal token, user.perishable_token
    end
  end

  test 'should reset perishable token and save the record' do
    user = new_user
    assert_nil user.perishable_token
    user.reset_perishable_token!
    assert_not_nil user.perishable_token
    assert !user.new_record?
  end

  test 'should save without validations when reseting perisable token' do
    user = new_user
    user.expects(:valid?).never
    user.reset_perishable_token!
  end

  test 'should never generate the same perishable token for different users' do
    perishable_tokens = []
    10.times do
      token = create_user.perishable_token
      assert !perishable_tokens.include?(token)
      perishable_tokens << token
    end
  end

  test 'should not change perishable token when updating' do
    user = create_user
    token = user.perishable_token
    user.expects(:perishable_token=).never
    user.save!
    assert_equal token, user.perishable_token
  end

  test 'should generate a sha1 hash for perishable token' do
    ActiveSupport::SecureRandom.expects(:base64).with(15).times(3).returns('perishable token')
    assert_equal 'perishable token', create_user.perishable_token
  end
end
