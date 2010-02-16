require 'test/test_helper'

class LockableTest < ActiveSupport::TestCase

  def setup
    setup_mailer
  end

  test "should increment failed attempts on unsuccessful authentication" do
    user = create_user
    assert_equal 0, user.failed_attempts

    authenticated_user = User.authenticate(:email => user.email, :password => "anotherpassword")
    assert_equal 1, user.reload.failed_attempts
  end

  test "should lock account base on maximum_attempts" do
    user = create_user
    attempts = Devise.maximum_attempts + 1
    attempts.times { authenticated_user = User.authenticate(:email => user.email, :password => "anotherpassword") }
    assert user.reload.locked?
  end

  test "should respect maximum attempts configuration" do
    user = create_user
    swap Devise, :maximum_attempts => 2 do
      3.times { authenticated_user = User.authenticate(:email => user.email, :password => "anotherpassword") }
      assert user.reload.locked?
    end
  end

  test "should clear failed_attempts on successfull sign in" do
    user = create_user
    User.authenticate(:email => user.email, :password => "anotherpassword")
    assert_equal 1, user.reload.failed_attempts
    User.authenticate(:email => user.email, :password => "123456")
    assert_equal 0, user.reload.failed_attempts
  end

  test "should verify wheter a user is locked or not" do
    user = create_user
    assert_not user.locked?
    user.lock!
    assert user.locked?
  end

  test "active? should be the opposite of locked?" do
    user = create_user
    user.confirm!
    assert user.active?
    user.lock!
    assert_not user.active?
  end

  test "should unlock an user by cleaning locked_at, falied_attempts and unlock_token" do
    user = create_user
    user.lock!
    assert_not_nil user.reload.locked_at
    assert_not_nil user.reload.unlock_token

    user.unlock!
    assert_nil user.reload.locked_at
    assert_nil user.reload.unlock_token
    assert 0, user.reload.failed_attempts
  end

  test 'should not unlock an unlocked user' do
    user = create_user
    assert_not user.unlock!
    assert_match "was not locked", user.errors[:email].join
  end

  test "new user should not be locked and should have zero failed_attempts" do
    assert_not new_user.locked?
    assert_equal 0, create_user.failed_attempts
  end

  test "should unlock user after unlock_in period" do
    swap Devise, :unlock_in => 3.hours do
      user = new_user
      user.locked_at = 2.hours.ago
      assert user.locked?

      Devise.unlock_in = 1.hour
      assert_not user.locked?
    end
  end

  test "should not unlock in 'unlock_in' if :time unlock strategy is not set" do
    swap Devise, :unlock_strategy => :email do
      user = new_user
      user.locked_at = 2.hours.ago
      assert user.locked?
    end
  end

  test "should set unlock_token when locking" do
    user = create_user
    assert_nil user.unlock_token
    user.lock!
    assert_not_nil user.unlock_token
  end

  test 'should not regenerate unlock token if it already exists' do
    user = create_user
    user.lock!
    3.times do
      token = user.unlock_token
      user.resend_unlock!
      assert_equal token, user.unlock_token
    end
  end

  test "should never generate the same unlock token for different users" do
    unlock_tokens = []
    3.times do
      user = create_user
      user.lock!
      token = user.unlock_token
      assert !unlock_tokens.include?(token)
      unlock_tokens << token
    end
  end

  test "should not generate unlock_token when :email is not an unlock strategy" do
    swap Devise, :unlock_strategy => :time do
      user = create_user
      user.lock!
      assert_nil user.unlock_token
    end
  end

  test "should send email with unlock instructions when :email is an unlock strategy" do
    swap Devise, :unlock_strategy => :email do
      user = create_user
      assert_email_sent do
        user.lock!
      end
    end
  end

  test "should not send email with unlock instructions when :email is not an unlock strategy" do
    swap Devise, :unlock_strategy => :time do
      user = create_user
      assert_email_not_sent do
        user.lock!
      end
    end
  end

  test 'should find and unlock an user automatically' do
    user = create_user
    user.lock!
    locked_user = User.unlock!(:unlock_token => user.unlock_token)
    assert_equal locked_user, user
    assert_not user.reload.locked?
  end

  test 'should return a new record with errors when a invalid token is given' do
    locked_user = User.unlock!(:unlock_token => 'invalid_token')
    assert locked_user.new_record?
    assert_equal "is invalid", locked_user.errors[:unlock_token].join
  end

  test 'should return a new record with errors when a blank token is given' do
    locked_user = User.unlock!(:unlock_token => '')
    assert locked_user.new_record?
    assert_equal "can't be blank", locked_user.errors[:unlock_token].join
  end

  test 'should authenticate a unlocked user' do
    user = create_user
    user.lock!
    user.unlock!
    authenticated_user = User.authenticate(:email => user.email, :password => user.password)
    assert_equal authenticated_user, user
  end

  test 'should find a user to send unlock instructions' do
    user = create_user
    user.lock!
    unlock_user = User.send_unlock_instructions(:email => user.email)
    assert_equal unlock_user, user
  end

  test 'should return a new user if no email was found' do
    unlock_user = User.send_unlock_instructions(:email => "invalid@email.com")
    assert unlock_user.new_record?
  end

  test 'should add error to new user email if no email was found' do
    unlock_user = User.send_unlock_instructions(:email => "invalid@email.com")
    assert_equal 'not found', unlock_user.errors[:email].join
  end

  test 'should not be able to send instructions if the user is not locked' do
    user = create_user
    assert_not user.resend_unlock!
    assert_not user.locked?
    assert_equal 'was not locked', user.errors[:email].join
  end

end
