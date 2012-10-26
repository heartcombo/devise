require 'test_helper'

class LockableTest < ActiveSupport::TestCase
  def setup
    setup_mailer
  end

  test "should respect maximum attempts configuration" do
    user = create_user
    user.confirm!
    swap Devise, :maximum_attempts => 2 do
      3.times { user.valid_for_authentication?{ false } }
      assert user.reload.access_locked?
    end
  end

  test "should increment failed_attempts on successfull validation if the user is already locked" do
    user = create_user
    user.confirm!

    swap Devise, :maximum_attempts => 2 do
      3.times { user.valid_for_authentication?{ false } }
      assert user.reload.access_locked?
    end

    user.valid_for_authentication?{ true }
    assert_equal 4, user.reload.failed_attempts
  end

  test "should not touch failed_attempts if lock_strategy is none" do
    user = create_user
    user.confirm!
    swap Devise, :lock_strategy => :none, :maximum_attempts => 2 do
      3.times { user.valid_for_authentication?{ false } }
      assert !user.access_locked?
      assert_equal 0, user.failed_attempts
    end
  end

  test 'should be valid for authentication with a unlocked user' do
    user = create_user
    user.lock_access!
    user.unlock_access!
    assert user.valid_for_authentication?{ true }
  end

  test "should verify whether a user is locked or not" do
    user = create_user
    assert_not user.access_locked?
    user.lock_access!
    assert user.access_locked?
  end

  test "active_for_authentication? should be the opposite of locked?" do
    user = create_user
    user.confirm!
    assert user.active_for_authentication?
    user.lock_access!
    assert_not user.active_for_authentication?
  end

  test "should unlock a user by cleaning locked_at, falied_attempts and unlock_token" do
    user = create_user
    user.lock_access!
    assert_not_nil user.reload.locked_at
    assert_not_nil user.reload.unlock_token

    user.unlock_access!
    assert_nil user.reload.locked_at
    assert_nil user.reload.unlock_token
    assert_equal 0, user.reload.failed_attempts
  end

  test "new user should not be locked and should have zero failed_attempts" do
    assert_not new_user.access_locked?
    assert_equal 0, create_user.failed_attempts
  end

  test "should unlock user after unlock_in period" do
    swap Devise, :unlock_in => 3.hours do
      user = new_user
      user.locked_at = 2.hours.ago
      assert user.access_locked?

      Devise.unlock_in = 1.hour
      assert_not user.access_locked?
    end
  end

  test "should not unlock in 'unlock_in' if :time unlock strategy is not set" do
    swap Devise, :unlock_strategy => :email do
      user = new_user
      user.locked_at = 2.hours.ago
      assert user.access_locked?
    end
  end

  test "should set unlock_token when locking" do
    user = create_user
    assert_nil user.unlock_token
    user.lock_access!
    assert_not_nil user.unlock_token
  end

  test "should never generate the same unlock token for different users" do
    unlock_tokens = []
    3.times do
      user = create_user
      user.lock_access!
      token = user.unlock_token
      assert !unlock_tokens.include?(token)
      unlock_tokens << token
    end
  end

  test "should not generate unlock_token when :email is not an unlock strategy" do
    swap Devise, :unlock_strategy => :time do
      user = create_user
      user.lock_access!
      assert_nil user.unlock_token
    end
  end

  test "should send email with unlock instructions when :email is an unlock strategy" do
    swap Devise, :unlock_strategy => :email do
      user = create_user
      assert_email_sent do
        user.lock_access!
      end
    end
  end

  test "should not send email with unlock instructions when :email is not an unlock strategy" do
    swap Devise, :unlock_strategy => :time do
      user = create_user
      assert_email_not_sent do
        user.lock_access!
      end
    end
  end

  test 'should find and unlock a user automatically' do
    user = create_user
    user.lock_access!
    locked_user = User.unlock_access_by_token(user.unlock_token)
    assert_equal locked_user, user
    assert_not user.reload.access_locked?
  end

  test 'should return a new record with errors when a invalid token is given' do
    locked_user = User.unlock_access_by_token('invalid_token')
    assert_not locked_user.persisted?
    assert_equal "is invalid", locked_user.errors[:unlock_token].join
  end

  test 'should return a new record with errors when a blank token is given' do
    locked_user = User.unlock_access_by_token('')
    assert_not locked_user.persisted?
    assert_equal "can't be blank", locked_user.errors[:unlock_token].join
  end

  test 'should find a user to send unlock instructions' do
    user = create_user
    user.lock_access!
    unlock_user = User.send_unlock_instructions(:email => user.email)
    assert_equal unlock_user, user
  end

  test 'should return a new user if no email was found' do
    unlock_user = User.send_unlock_instructions(:email => "invalid@example.com")
    assert_not unlock_user.persisted?
  end

  test 'should add error to new user email if no email was found' do
    unlock_user = User.send_unlock_instructions(:email => "invalid@example.com")
    assert_equal 'not found', unlock_user.errors[:email].join
  end

  test 'should find a user to send unlock instructions by authentication_keys' do
    swap Devise, :authentication_keys => [:username, :email] do
      user = create_user
      unlock_user = User.send_unlock_instructions(:email => user.email, :username => user.username)
      assert_equal unlock_user, user
    end
  end

  test 'should require all unlock_keys' do
      swap Devise, :unlock_keys => [:username, :email] do
          user = create_user
          unlock_user = User.send_unlock_instructions(:email => user.email)
          assert_not unlock_user.persisted?
          assert_equal "can't be blank", unlock_user.errors[:username].join
      end
  end

  test 'should not be able to send instructions if the user is not locked' do
    user = create_user
    assert_not user.resend_unlock_token
    assert_not user.access_locked?
    assert_equal 'was not locked', user.errors[:email].join
  end

  test 'should unlock account if lock has expired and increase attempts on failure' do
    swap Devise, :unlock_in => 1.minute do
      user = create_user
      user.confirm!

      user.failed_attempts = 2
      user.locked_at = 2.minutes.ago

      user.valid_for_authentication? { false }
      assert_equal 1, user.failed_attempts
    end
  end

  test 'should unlock account if lock has expired on success' do
    swap Devise, :unlock_in => 1.minute do
      user = create_user
      user.confirm!

      user.failed_attempts = 2
      user.locked_at = 2.minutes.ago

      user.valid_for_authentication? { true }
      assert_equal 0, user.failed_attempts
      assert_nil user.locked_at
    end
  end

  test 'required_fields should contain the all the fields when all the strategies are enabled' do
    swap Devise, :unlock_strategy => :both do
      swap Devise, :lock_strategy => :failed_attempts do
        assert_same_content Devise::Models::Lockable.required_fields(User), [
         :failed_attempts,
         :locked_at,
         :unlock_token
        ]
      end
    end
  end

  test 'required_fields should contain only failed_attempts and locked_at when the strategies are time and failed_attempts are enabled' do
    swap Devise, :unlock_strategy => :time do
      swap Devise, :lock_strategy => :failed_attempts do
        assert_same_content Devise::Models::Lockable.required_fields(User), [
         :failed_attempts,
         :locked_at
        ]
      end
    end
  end

  test 'required_fields should contain only failed_attempts and unlock_token when the strategies are token and failed_attempts are enabled' do
    swap Devise, :unlock_strategy => :email do
      swap Devise, :lock_strategy => :failed_attempts do
        assert_same_content Devise::Models::Lockable.required_fields(User), [
         :failed_attempts,
         :unlock_token
        ]
      end
    end
  end

  test 'should not return a locked unauthenticated message if in paranoid mode' do
    swap Devise, :paranoid => :true do
      user = create_user
      user.failed_attempts = Devise.maximum_attempts + 1
      user.lock_access!

      assert_equal :invalid, user.unauthenticated_message
    end
  end
end
