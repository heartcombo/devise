require 'test/test_helper'

class ConfirmableTest < ActiveSupport::TestCase

  def setup
    setup_mailer
  end

  test 'should generate confirmation token after creating a record' do
    assert_nil new_user.confirmation_token
    assert_not_nil create_user.confirmation_token
  end

  test 'should regenerate confirmation token each time' do
    user = create_user
    3.times do
      token = user.confirmation_token
      user.reset_confirmation!
      assert_not_equal token, user.confirmation_token
    end
  end

  test 'should never generate the same confirmation token for different users' do
    confirmation_tokens = []
    10.times do
      token = create_user.confirmation_token
      assert !confirmation_tokens.include?(token)
      confirmation_tokens << token
    end
  end

  test 'should confirm a user updating confirmed at' do
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

  test 'should not confirm a user already confirmed and add an error to email' do
    user = create_user
    assert user.confirm!
    assert_nil user.errors[:email]
    assert_not user.confirm!
    assert_not_nil user.errors[:email]
    assert_equal 'already confirmed', user.errors[:email]
  end

  test 'should find and confirm an user automatically' do
    user = create_user
    confirmed_user = User.confirm!(:confirmation_token => user.confirmation_token)
    assert_not_nil confirmed_user
    assert_equal confirmed_user, user
    assert user.reload.confirmed?
  end

  test 'should return a new user with errors if no user exists while trying to confirm' do
    confirmed_user = User.confirm!(:confirmation_token => 'invalid_confirmation_token')
    assert confirmed_user.new_record?
  end

  test 'should return errors for a new user when trying to confirm' do
    confirmed_user = User.confirm!(:confirmation_token => 'invalid_confirmation_token')
    assert_not_nil confirmed_user.errors[:confirmation_token]
    assert_equal 'is invalid', confirmed_user.errors[:confirmation_token]
  end

  test 'should generate errors for a user email if user is already confirmed' do
    user = create_user
    user.confirm!
    confirmed_user = User.confirm!(:confirmation_token => user.confirmation_token)
    assert confirmed_user.confirmed?
    assert confirmed_user.errors[:email]
  end

  test 'should authenticate a confirmed user' do
    user = create_user
    user.confirm!
    authenticated_user = User.authenticate(:email => user.email, :password => user.password)
    assert_not_nil authenticated_user
    assert_equal authenticated_user, user
  end

  test 'should send confirmation instructions by email' do
    assert_email_sent do
      create_user
    end
  end

  test 'should not send confirmation when trying to save an invalid user' do
    assert_email_not_sent do
      user = new_user
      user.stubs(:valid?).returns(false)
      user.save
    end
  end

  test 'should find a user to send confirmation instructions' do
    user = create_user
    confirmation_user = User.send_confirmation_instructions(:email => user.email)
    assert_not_nil confirmation_user
    assert_equal confirmation_user, user
  end

  test 'should return a new user if no email was found' do
    confirmation_user = User.send_confirmation_instructions(:email => "invalid@email.com")
    assert_not_nil confirmation_user
    assert confirmation_user.new_record?
  end

  test 'should add error to new user email if no email was found' do
    confirmation_user = User.send_confirmation_instructions(:email => "invalid@email.com")
    assert confirmation_user.errors[:email]
    assert_equal 'not found', confirmation_user.errors[:email]
  end

  test 'should reset confirmation token before send the confirmation instructions email' do
    user = create_user
    token = user.confirmation_token
    confirmation_user = User.send_confirmation_instructions(:email => user.email)
    assert_not_equal token, user.reload.confirmation_token
  end

  test 'should reset confirmation status when sending the confirmation instructions' do
    user = create_user
    assert_not user.confirmed?
    confirmation_user = User.send_confirmation_instructions(:email => user.email)
    assert_not user.reload.confirmed?
  end

  test 'should send email instructions for the user confirm it\'s email' do
    user = create_user
    assert_email_sent do
      User.send_confirmation_instructions(:email => user.email)
    end
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
    assert_not user.reset_confirmation!
    assert user.confirmed?
    assert user.errors[:email].present?
    assert_equal 'already confirmed', user.errors[:email]
  end

  test 'confirm time should fallback to devise confirm in default configuration' do
    begin
      confirm_within = Devise::Models.confirm_within
      Devise::Models.confirm_within = 1.day
      user = new_user
      user.confirmation_sent_at = 2.days.ago
      assert_not user.active?
      Devise::Models.confirm_within = 3.days
      assert user.active?
    ensure
      Devise::Models.confirm_within = confirm_within
    end
  end

  test 'should be active when confirmation sent at is not overpast' do
    Devise::Models.confirm_within = 5.days
    user = create_user
    user.confirmation_sent_at = 4.days.ago
    assert user.active?
  end

  test 'should be active when already confirmed' do
    user = create_user
    assert_not user.confirmed?
    assert_not user.active?
    user.confirm!
    assert user.confirmed?
    assert user.active?
  end

  test 'should not be active when confirmation was sent within the limit' do
    Devise::Models.confirm_within = 5.days
    user = create_user
    user.confirmation_sent_at = 5.days.ago
    assert_not user.active?
  end

  test 'should be active when confirm in is zero' do
    Devise::Models.confirm_within = 0.days
    user = create_user
    user.confirmation_sent_at = Date.today
    assert_not user.active?
  end

  test 'should not be active when confirmation was sent before confirm in time' do
    Devise::Models.confirm_within = 4.days
    user = create_user
    user.confirmation_sent_at = 5.days.ago
    assert_not user.active?
  end

  test 'should not be active without confirmation' do
    user = create_user
    user.update_attribute(:confirmation_sent_at, nil)
    assert_not user.reload.active?
  end

end
