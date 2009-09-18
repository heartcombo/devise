require 'test_helper'

class ConfirmableTest < ActiveSupport::TestCase

  def setup
    # Todo: refactor this!
    User.send :include, ::Devise::Confirmable unless User.included_modules.include?(::Devise::Confirmable)
    setup_mailer
  end

  test 'should not have confirmation code accessible' do
    assert_not field_accessible?(:confirmation_token)
  end

  test 'should not have confirmed at accessible' do
    assert_not field_accessible?(:confirmed_at)
  end

  test 'should generate confirmation token after creating a record' do
    assert_nil new_user.confirmation_token
    assert_not_nil create_user.confirmation_token
  end

  test 'should generate a sha1 hash for confirmation token' do
    now = Time.now
    Time.stubs(:now).returns(now)
    User.any_instance.stubs(:random_string).returns('random_string')
    expected_token = ::Digest::SHA1.hexdigest("--#{now.utc}--random_string--12345--")
    user = create_user
    assert_equal expected_token, user.confirmation_token
  end

  test 'should never generate the same confirmation_token for different users' do
    confirmation_tokens = []
    10.times do
      token = create_user.confirmation_token
      assert !confirmation_tokens.include?(token)
      confirmation_tokens << token
    end
  end

  test 'should not change confirmation token when updating' do
    user = create_user
    token = user.confirmation_token
    user.expects(:confirmation_token=).never
    user.save!
    assert_equal token, user.confirmation_token
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
    confirmed_user = User.find_and_confirm(user.confirmation_token)
    assert_not_nil confirmed_user
    assert_equal confirmed_user, user
    assert user.reload.confirmed?
  end

  test 'should return a new user with errors if no user exists while trying to confirm' do
    confirmed_user = User.find_and_confirm('invalid_confirmation_token')
    assert confirmed_user.new_record?
    assert_not_nil confirmed_user.errors[:confirmation_token]
    assert_equal "invalid confirmation", confirmed_user.errors[:confirmation_token]
  end

  test 'should generate errors for a user email if user is already confirmed' do
    user = create_user
    user.confirm!
    confirmed_user = User.find_and_confirm(user.confirmation_token)
    assert confirmed_user.confirmed?
    assert confirmed_user.errors[:email]
  end

  test 'should not authenticate a user not confirmed' do
    user = create_user
    authenticated_user = User.authenticate(user.email, user.password)
    assert_nil authenticated_user
  end

  test 'should authenticate a confirmed user' do
    user = create_user
    user.confirm!
    authenticated_user = User.authenticate(user.email, user.password)
    assert_not_nil authenticated_user
    assert_equal authenticated_user, user
  end

  test 'should send confirmation instructions by email' do
    assert_difference 'ActionMailer::Base.deliveries.size' do
      create_user
    end
  end

  test 'should not send confirmation when trying to save an invalid user' do
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      user = new_user
      user.stubs(:valid?).returns(false)
      user.save
    end
  end
end

