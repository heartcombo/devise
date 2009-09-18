require 'test_helper'

class ConfirmableTest < ActiveSupport::TestCase

  def setup
    # Todo: refactor this!
    User.send :include, ::Devise::Confirmable unless User.included_modules.include?(::Devise::Confirmable)
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
    confirmed_user = User.find_and_confirm(user.perishable_token)
    assert_not_nil confirmed_user
    assert_equal confirmed_user, user
    assert user.reload.confirmed?
  end

  test 'should return a new user with errors if no user exists while trying to confirm' do
    confirmed_user = User.find_and_confirm('invalid_perishable_token')
    assert confirmed_user.new_record?
    assert_not_nil confirmed_user.errors[:perishable_token]
    assert_equal "invalid confirmation", confirmed_user.errors[:perishable_token]
  end

  test 'should generate errors for a user email if user is already confirmed' do
    user = create_user
    user.confirm!
    confirmed_user = User.find_and_confirm(user.perishable_token)
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

