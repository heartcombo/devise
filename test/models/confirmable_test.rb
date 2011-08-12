require 'test_helper'

class ConfirmableTest < ActiveSupport::TestCase

  def setup
    setup_mailer
  end

  test 'should generate confirmation token after creating a record' do
    assert_nil new_user.confirmation_token
    assert_not_nil create_user.confirmation_token
  end

  test 'should never generate the same confirmation token for different users' do
    confirmation_tokens = []
    3.times do
      token = create_user.confirmation_token
      assert !confirmation_tokens.include?(token)
      confirmation_tokens << token
    end
  end

  test 'should confirm a user by updating confirmed at' do
    user = create_user
    assert_nil user.confirmed_at
    assert user.confirm!
    assert_not_nil user.confirmed_at
  end

  test 'should clear confirmation token while confirming a user' do
    user = create_user
    assert_present user.confirmation_token
    user.confirm!
    assert_nil user.confirmation_token
  end

  test 'should verify whether a user is confirmed or not' do
    assert_not new_user.confirmed?
    user = create_user
    assert_not user.confirmed?
    user.confirm!
    assert user.confirmed?
  end

  test 'should not confirm a user already confirmed' do
    user = create_user
    assert user.confirm!
    assert_blank user.errors[:email]

    assert_not user.confirm!
    assert_equal "was already confirmed, please try signing in", user.errors[:email].join
  end

  test 'should find and confirm a user automatically' do
    user = create_user
    confirmed_user = User.confirm_by_token(user.confirmation_token)
    assert_equal confirmed_user, user
    assert user.reload.confirmed?
  end

  test 'should return a new record with errors when a invalid token is given' do
    confirmed_user = User.confirm_by_token('invalid_confirmation_token')
    assert_not confirmed_user.persisted?
    assert_equal "is invalid", confirmed_user.errors[:confirmation_token].join
  end

  test 'should return a new record with errors when a blank token is given' do
    confirmed_user = User.confirm_by_token('')
    assert_not confirmed_user.persisted?
    assert_equal "can't be blank", confirmed_user.errors[:confirmation_token].join
  end

  test 'should generate errors for a user email if user is already confirmed' do
    user = create_user
    user.confirmed_at = Time.now
    user.save
    confirmed_user = User.confirm_by_token(user.confirmation_token)
    assert confirmed_user.confirmed?
    assert_equal "was already confirmed, please try signing in", confirmed_user.errors[:email].join
  end

  test 'should send confirmation instructions by email' do
    assert_email_sent "mynewuser@example.com" do
      create_user :email => "mynewuser@example.com"
    end
  end

  test 'should not send confirmation when trying to save an invalid user' do
    assert_email_not_sent do
      user = new_user
      user.stubs(:valid?).returns(false)
      user.save
    end
  end

  test 'should not generate a new token neither send e-mail if skip_confirmation! is invoked' do
    user = new_user
    user.skip_confirmation!

    assert_email_not_sent do
      user.save!
      assert_nil user.confirmation_token
      assert_not_nil user.confirmed_at
    end
  end

  test 'should find a user to send confirmation instructions' do
    user = create_user
    confirmation_user = User.send_confirmation_instructions(:email => user.email)
    assert_equal confirmation_user, user
  end

  test 'should return a new user if no email was found' do
    confirmation_user = User.send_confirmation_instructions(:email => "invalid@example.com")
    assert_not confirmation_user.persisted?
  end

  test 'should add error to new user email if no email was found' do
    confirmation_user = User.send_confirmation_instructions(:email => "invalid@example.com")
    assert confirmation_user.errors[:email]
    assert_equal "not found", confirmation_user.errors[:email].join
  end

  test 'should send email instructions for the user confirm its email' do
    user = create_user
    assert_email_sent user.email do
      User.send_confirmation_instructions(:email => user.email)
    end
  end

  test 'should always have confirmation token when email is sent' do
    user = new_user
    user.instance_eval { def confirmation_required?; false end }
    user.save
    user.send_confirmation_instructions
    assert_not_nil user.reload.confirmation_token
  end

  test 'should not resend email instructions if the user change his email' do
    user = create_user
    user.email = 'new_test@example.com'
    assert_email_not_sent do
      user.save!
    end
  end

  test 'should not reset confirmation status or token when updating email' do
    user = create_user
    user.confirm!
    user.email = 'new_test@example.com'
    user.save!

    user.reload
    assert user.confirmed?
    assert_nil user.confirmation_token
  end

  test 'should not be able to send instructions if the user is already confirmed' do
    user = create_user
    user.confirm!
    assert_not user.resend_confirmation_token
    assert user.confirmed?
    assert_equal 'was already confirmed, please try signing in', user.errors[:email].join
  end

  test 'confirm time should fallback to devise confirm in default configuration' do
    swap Devise, :confirm_within => 1.day do
      user = new_user
      user.confirmation_sent_at = 2.days.ago
      assert_not user.active_for_authentication?

      Devise.confirm_within = 3.days
      assert user.active_for_authentication?
    end
  end

  test 'should be active when confirmation sent at is not overpast' do
    swap Devise, :confirm_within => 5.days do
      Devise.confirm_within = 5.days
      user = create_user

      user.confirmation_sent_at = 4.days.ago
      assert user.active_for_authentication?

      user.confirmation_sent_at = 5.days.ago
      assert_not user.active_for_authentication?
    end
  end

  test 'should be active when already confirmed' do
    user = create_user
    assert_not user.confirmed?
    assert_not user.active_for_authentication?

    user.confirm!
    assert user.confirmed?
    assert user.active_for_authentication?
  end

  test 'should not be active when confirm in is zero' do
    Devise.confirm_within = 0.days
    user = create_user
    user.confirmation_sent_at = Date.today
    assert_not user.active_for_authentication?
  end

  test 'should not be active without confirmation' do
    user = create_user
    user.confirmation_sent_at = nil
    user.save
    assert_not user.reload.active_for_authentication?
  end

  test 'should be active without confirmation when confirmation is not required' do
    user = create_user
    user.instance_eval { def confirmation_required?; false end }
    user.confirmation_sent_at = nil
    user.save
    assert user.reload.active_for_authentication?
  end

  test 'should find a user to send email instructions for the user confirm its email by authentication_keys' do
    swap Devise, :authentication_keys => [:username, :email] do
      user = create_user
      confirm_user = User.send_confirmation_instructions(:email => user.email, :username => user.username)
      assert_equal confirm_user, user
    end
  end

  test 'should require all confirmation_keys' do
    swap Devise, :confirmation_keys => [:username, :email] do
      user = create_user
      confirm_user = User.send_confirmation_instructions(:email => user.email)
      assert_not confirm_user.persisted?
      assert_equal "can't be blank", confirm_user.errors[:username].join
    end
  end
end

class ReconfirmableTest < ConfirmableTest
  def setup
    add_unconfirmed_email_column
    Devise.reconfirmable = true
  end

  def teardown
    remove_unconfirmed_email_column
    Devise.reconfirmable = false
  end

  def test_should_not_resend_email_instructions_if_the_user_change_his_email
    #behaves differently
  end

  def test_should_not_reset_confirmation_status_or_token_when_updating_email
    #behaves differently
  end

  test 'should generate confirmation token after changing email' do
    user = create_user
    assert user.confirm!
    assert_nil user.confirmation_token
    assert user.update_attributes(:email => 'new_test@example.com')
    assert_not_nil user.confirmation_token
  end

  test 'should send confirmation instructions by email after changing email' do
    user = create_user
    assert user.confirm!
    assert_email_sent "new_test@example.com" do
      assert user.update_attributes(:email => 'new_test@example.com')
    end
  end

  test 'should not send confirmation by email after changing password' do
    user = create_user
    assert user.confirm!
    assert_email_not_sent do
      assert user.update_attributes(:password => 'newpass', :password_confirmation => 'newpass')
    end
  end

  test 'should stay confirmed when email is changed' do
    user = create_user
    assert user.confirm!
    assert user.update_attributes(:email => 'new_test@example.com')
    assert user.confirmed?
  end

  test 'should update email only when it is confirmed' do
    user = create_user
    assert user.confirm!
    assert user.update_attributes(:email => 'new_test@example.com')
    assert_not_equal 'new_test@example.com', user.email
    assert user.confirm!
    assert_equal 'new_test@example.com', user.email
  end

  test 'should not allow user to get past confirmation email by resubmitting their new address' do
    user = create_user
    assert user.confirm!
    assert user.update_attributes(:email => 'new_test@example.com')
    assert_not_equal 'new_test@example.com', user.email
    assert user.update_attributes(:email => 'new_test@example.com')
    assert_not_equal 'new_test@example.com', user.email
  end

  test 'should find a user by send confirmation instructions with unconfirmed_email' do
    user = create_user
    assert user.confirm!
    assert user.update_attributes(:email => 'new_test@example.com')
    confirmation_user = User.send_confirmation_instructions(:email => user.unconfirmed_email)
    assert_equal confirmation_user, user
  end

  test 'should return a new user if no email or unconfirmed_email was found' do
    confirmation_user = User.send_confirmation_instructions(:email => "invalid@email.com")
    assert_not confirmation_user.persisted?
  end

  test 'should add error to new user email if no email or unconfirmed_email was found' do
    confirmation_user = User.send_confirmation_instructions(:email => "invalid@email.com")
    assert confirmation_user.errors[:email]
    assert_equal "not found", confirmation_user.errors[:email].join
  end

  test 'should find user with email in unconfirmed_emails' do
    user = create_user
    user.unconfirmed_email = "new_test@email.com"
    assert user.save
    user = User.find_by_unconfirmed_email_with_errors(:email => "new_test@email.com")
    assert user.persisted?
  end
end
