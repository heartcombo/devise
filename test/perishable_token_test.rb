require 'test_helper'

class PerishableTokenTest < ActiveSupport::TestCase

  def setup
    User.send :include, ::Devise::PerishableToken unless User.included_modules.include?(::Devise::PerishableToken)
  end

  test 'should not have perishable token accessible' do
    assert_not field_accessible?(:perishable_token)
  end

  test 'should generate perishable token after creating a record' do
    assert_nil new_user.perishable_token
    assert_not_nil create_user.perishable_token
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
    now = Time.now
    Time.stubs(:now).returns(now)
    User.any_instance.stubs(:random_string).returns('random_string')
    expected_token = ::Digest::SHA1.hexdigest("--#{now.utc}--random_string--12345--")
    user = create_user
    assert_equal expected_token, user.perishable_token
  end
end

