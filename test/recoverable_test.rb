require 'test_helper'

class RecoverableTest < ActiveSupport::TestCase

  def setup
    User.send :include, ::Devise::Recoverable unless User.included_modules.include?(::Devise::Recoverable)
    @user = create_user
    setup_mailer
  end

  test 'should reset password and password confirmation from params' do
    @user.reset_password('56789', '98765')
    assert_equal '56789', @user.password
    assert_equal '98765', @user.password_confirmation
  end

  test 'should reset password and save the record' do
    assert @user.reset_password!('56789', '56789')
  end

  test 'should not reset password with invalid data' do
    @user.stubs(:valid?).returns(false)
    assert_not @user.reset_password!('56789', '98765')
  end

  test 'should find a user to send instructions by email' do
    reset_password_user = User.find_and_send_reset_password_instructions(@user.email)
    assert_not_nil reset_password_user
    assert_equal reset_password_user, @user
  end

  test 'should return a new user if no email was found' do
    reset_password_user = User.find_and_send_reset_password_instructions("invalid@email.com")
    assert_not_nil reset_password_user
    assert reset_password_user.new_record?
  end

  test 'should add error to new user email if no email was found' do
    reset_password_user = User.find_and_send_reset_password_instructions("invalid@email.com")
    assert reset_password_user.errors[:email]
    assert_equal 'not found', reset_password_user.errors[:email]
  end

  test 'should reset perishable token before send the reset instrunctions email' do
    token = @user.perishable_token
    reset_password_user = User.find_and_send_reset_password_instructions(@user.email)
    assert_not_equal token, @user.reload.perishable_token
  end

  test 'should send email instructions to the user' do
    assert_email_sent do
      User.find_and_send_reset_password_instructions(@user.email)
    end
  end
end

