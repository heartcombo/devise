require 'test/test_helper'

class ConfirmableTest < ActiveSupport::TestCase

  def setup
    setup_mailer
  end

  test 'should not have confirmed at accessible' do
    assert_not field_accessible?(:confirmed_at)
  end

  test 'should confirm a user updating confirmed at' do
    user = create_user
    assert_nil user.confirmed_at
    assert user.confirm!
    assert_not_nil user.confirmed_at
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
    confirmed_user = User.confirm!(:perishable_token => user.perishable_token)
    assert_not_nil confirmed_user
    assert_equal confirmed_user, user
    assert user.reload.confirmed?
  end

  test 'should return a new user with errors if no user exists while trying to confirm' do
    confirmed_user = User.confirm!(:perishable_token => 'invalid_perishable_token')
    assert confirmed_user.new_record?
  end

  test 'should return errors for a new user when trying to confirm' do
    confirmed_user = User.confirm!(:perishable_token => 'invalid_perishable_token')
    assert_not_nil confirmed_user.errors[:perishable_token]
    assert_equal "invalid confirmation", confirmed_user.errors[:perishable_token]
  end

  test 'should generate errors for a user email if user is already confirmed' do
    user = create_user
    user.confirm!
    confirmed_user = User.confirm!(:perishable_token => user.perishable_token)
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

  test 'should reset perishable token before send the confirmation instructions email' do
    user = create_user
    token = user.perishable_token
    confirmation_user = User.send_confirmation_instructions(:email => user.email)
    assert_not_equal token, user.reload.perishable_token
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

  test 'should resend email instructions for the user reconfirming the email if it has changed' do
    user = create_user
    user.email = 'new_test@example.com'
    assert_email_sent do
      user.save!
    end
  end

  test 'should not resend email instructions if the user is updated but the email is not' do
    user = create_user
    user.confirmed_at = Time.now
    assert_email_not_sent do
      user.save!
    end
  end

  test 'should reset confirmation status when updating email' do
    user = create_user
    assert_not user.confirmed?
    user.confirm!
    assert user.confirmed?
    user.email = 'new_test@example.com'
    user.save!
    assert_not user.reload.confirmed?
  end

  test 'should reset perishable token when updating email' do
    user = create_user
    token = user.perishable_token
    user.email = 'new_test@example.com'
    user.save!
    assert_not_equal token, user.reload.perishable_token
  end

  test 'should not be able to send instructions if the user is already confirmed' do
    user = create_user
    user.confirm!
    assert_not user.reset_confirmation!
    assert user.confirmed?
    assert user.errors[:email].present?
    assert_equal 'already confirmed', user.errors[:email]
  end
end
