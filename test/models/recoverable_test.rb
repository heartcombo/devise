require 'test_helper'

class RecoverableTest < ActiveSupport::TestCase

  def setup
    setup_mailer
  end

  test 'should not generate reset password token after creating a record' do
    assert_nil new_user.reset_password_token
  end

  test 'should never generate the same reset password token for different users' do
    reset_password_tokens = []
    3.times do
      user = create_user
      user.send_reset_password_instructions
      token = user.reset_password_token
      assert !reset_password_tokens.include?(token)
      reset_password_tokens << token
    end
  end

  test 'should reset password and password confirmation from params' do
    user = create_user
    user.reset_password!('123456789', '987654321')
    assert_equal '123456789', user.password
    assert_equal '987654321', user.password_confirmation
  end

  test 'should reset password and save the record' do
    assert create_user.reset_password!('123456789', '123456789')
  end

  test 'should clear reset password token while reseting the password' do
    user = create_user
    assert_nil user.reset_password_token

    user.send_reset_password_instructions
    assert_present user.reset_password_token
    assert user.reset_password!('123456789', '123456789')
    assert_nil user.reset_password_token
  end

  test 'should not clear reset password token if record is invalid' do
    user = create_user
    user.send_reset_password_instructions
    assert_present user.reset_password_token
    assert_not user.reset_password!('123456789', '987654321')
    assert_present user.reset_password_token
  end

  test 'should not reset password with invalid data' do
    user = create_user
    user.stubs(:valid?).returns(false)
    assert_not user.reset_password!('123456789', '987654321')
  end

  test 'should reset reset password token and send instructions by email' do
    user = create_user
    assert_email_sent do
      token = user.reset_password_token
      user.send_reset_password_instructions
      assert_not_equal token, user.reset_password_token
    end
  end

  test 'should find a user to send instructions by email' do
    user = create_user
    reset_password_user = User.send_reset_password_instructions(:email => user.email)
    assert_equal reset_password_user, user
  end

  test 'should return a new record with errors if user was not found by e-mail' do
    reset_password_user = User.send_reset_password_instructions(:email => "invalid@example.com")
    assert_not reset_password_user.persisted?
    assert_equal "not found", reset_password_user.errors[:email].join
  end

  test 'should find a user to send instructions by authentication_keys' do
    swap Devise, :authentication_keys => [:username, :email] do
      user = create_user
      reset_password_user = User.send_reset_password_instructions(:email => user.email, :username => user.username)
      assert_equal reset_password_user, user
    end
  end

  test 'should require all reset_password_keys' do
      swap Devise, :reset_password_keys => [:username, :email] do
          user = create_user
          reset_password_user = User.send_reset_password_instructions(:email => user.email)
          assert_not reset_password_user.persisted?
          assert_equal "can't be blank", reset_password_user.errors[:username].join
      end
  end

  test 'should reset reset_password_token before send the reset instructions email' do
    user = create_user
    token = user.reset_password_token
    User.send_reset_password_instructions(:email => user.email)
    assert_not_equal token, user.reload.reset_password_token
  end

  test 'should send email instructions to the user reset his password' do
    user = create_user
    assert_email_sent do
      User.send_reset_password_instructions(:email => user.email)
    end
  end

  test 'should find a user to reset his password based on reset_password_token' do
    user = create_user
    user.send :generate_reset_password_token!

    reset_password_user = User.reset_password_by_token(:reset_password_token => user.reset_password_token)
    assert_equal reset_password_user, user
  end

  test 'should return a new record with errors if no reset_password_token is found' do
    reset_password_user = User.reset_password_by_token(:reset_password_token => 'invalid_token')
    assert_not reset_password_user.persisted?
    assert_equal "is invalid", reset_password_user.errors[:reset_password_token].join
  end

  test 'should return a new record with errors if reset_password_token is blank' do
    reset_password_user = User.reset_password_by_token(:reset_password_token => '')
    assert_not reset_password_user.persisted?
    assert_match "can't be blank", reset_password_user.errors[:reset_password_token].join
  end

  test 'should return a new record with errors if password is blank' do
    user = create_user
    user.send :generate_reset_password_token!

    reset_password_user = User.reset_password_by_token(:reset_password_token => user.reset_password_token, :password => '')
    assert_not reset_password_user.errors.empty?
    assert_match "can't be blank", reset_password_user.errors[:password].join
  end

  test 'should reset successfully user password given the new password and confirmation' do
    user = create_user
    old_password = user.password
    user.send :generate_reset_password_token!

    User.reset_password_by_token(
      :reset_password_token => user.reset_password_token,
      :password => 'new_password',
      :password_confirmation => 'new_password'
    )
    user.reload

    assert_not user.valid_password?(old_password)
    assert user.valid_password?('new_password')
  end

  test 'should not reset reset password token during reset_password_within time' do
    swap Devise, :reset_password_within => 1.hour do
      user = create_user
      user.send_reset_password_instructions
      3.times do
        token = user.reset_password_token
        user.send_reset_password_instructions
        assert_equal token, user.reset_password_token
      end
    end
  end

  test 'should reset reset password token after reset_password_within time' do
    swap Devise, :reset_password_within => 1.hour do
      user = create_user
      user.reset_password_sent_at = 2.days.ago
      token = user.reset_password_token
      user.send_reset_password_instructions
      assert_not_equal token, user.reset_password_token
    end
  end

  test 'should not reset password after reset_password_within time' do
    swap Devise, :reset_password_within => 1.hour do
      user = create_user
      old_password = user.password
      user.send :generate_reset_password_token!
      user.reset_password_sent_at = 2.days.ago
      user.save!

      reset_password_user = User.reset_password_by_token(
        :reset_password_token => user.reset_password_token,
        :password => 'new_password',
        :password_confirmation => 'new_password'
      )
      user.reload

      assert user.valid_password?(old_password)
      assert_not user.valid_password?('new_password')
      assert_equal "has expired, please request a new one", reset_password_user.errors[:reset_password_token].join
    end
  end

  test 'required_fields should contain the fields that Devise uses' do
    assert_same_content Devise::Models::Recoverable.required_fields(User), [
      :reset_password_sent_at,
      :reset_password_token
    ]
  end
end
