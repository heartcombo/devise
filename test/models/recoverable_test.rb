require 'test/test_helper'

class RecoverableTest < ActiveSupport::TestCase

  def setup
    setup_mailer
  end

  test 'should reset password and password confirmation from params' do
    user = create_user
    user.reset_password('123456789', '987654321')
    assert_equal '123456789', user.password
    assert_equal '987654321', user.password_confirmation
  end

  test 'should reset password and save the record' do
    assert create_user.reset_password!('123456789', '123456789')
  end

  test 'should clear perishable token while reseting the password' do
    user = create_user
    assert_present user.perishable_token
    user.reset_password!('123456789', '123456789')
    assert_nil user.perishable_token
  end

  test 'should not reset password with invalid data' do
    user = create_user
    user.stubs(:valid?).returns(false)
    assert_not user.reset_password!('123456789', '987654321')
  end

  test 'should reset perishable token and send instructions by email' do
    user = create_user
    assert_email_sent do
      token = user.perishable_token
      user.send_reset_password_instructions
      assert_not_equal token, user.perishable_token
    end
  end

  test 'should find a user to send instructions by email' do
    user = create_user
    reset_password_user = User.send_reset_password_instructions(:email => user.email)
    assert_not_nil reset_password_user
    assert_equal reset_password_user, user
  end

  test 'should return a new user if no email was found' do
    reset_password_user = User.send_reset_password_instructions(:email => "invalid@email.com")
    assert_not_nil reset_password_user
    assert reset_password_user.new_record?
  end

  test 'should add error to new user email if no email was found' do
    reset_password_user = User.send_reset_password_instructions(:email => "invalid@email.com")
    assert reset_password_user.errors[:email]
    assert_equal 'not found', reset_password_user.errors[:email]
  end

  test 'should reset perishable token before send the reset instructions email' do
    user = create_user
    token = user.perishable_token
    reset_password_user = User.send_reset_password_instructions(:email => user.email)
    assert_not_equal token, user.reload.perishable_token
  end

  test 'should send email instructions to the user reset it\'s password' do
    user = create_user
    assert_email_sent do
      User.send_reset_password_instructions(:email => user.email)
    end
  end

  test 'should find a user to reset it\'s password based on perishable_token' do
    user = create_user
    reset_password_user = User.reset_password!(:perishable_token => user.perishable_token)
    assert_not_nil reset_password_user
    assert_equal reset_password_user, user
  end

  test 'should return a new user when trying to reset it\'s password if no perishable_token is found' do
    reset_password_user = User.reset_password!(:perishable_token => 'invalid_token')
    assert_not_nil reset_password_user
    assert reset_password_user.new_record?
  end

  test 'should add error to new user email if no perishable token was found' do
    reset_password_user = User.reset_password!(:perishable_token => "invalid_token")
    assert reset_password_user.errors[:perishable_token]
    assert_equal 'invalid confirmation', reset_password_user.errors[:perishable_token]
  end

  test 'should reset successfully user password given the new password and confirmation' do
    user = create_user
    old_password = user.password
    reset_password_user = User.reset_password!(
      :perishable_token => user.perishable_token,
      :password => 'new_password',
      :password_confirmation => 'new_password'
    )
    user.reload
    assert_not user.valid_password?(old_password)
    assert user.valid_password?('new_password')
  end
end
