require 'test_helper'

class ValidatableTest < ActiveSupport::TestCase

  def setup
    User.send :include, ::Devise::Validatable unless User.included_modules.include?(::Devise::Validatable)
  end

  test 'should require email to be set' do
    user = new_user(:email => nil)
    assert user.invalid?
    assert user.errors[:email]
    assert_equal 'can\'t be blank', user.errors[:email]
  end

  test 'should require uniqueness of email, allowing blank' do
    existing_user = create_user
    user = new_user(:email => '')
    assert user.invalid?
    assert_not_equal 'has already been taken', user.errors[:email]
    user.email = existing_user.email
    assert user.invalid?
    assert user.errors[:email]
    assert_equal 1, user.errors[:email].to_a.size
    assert_equal 'has already been taken', user.errors[:email]
  end

  test 'should require correct email format, allowing blank' do
    user = new_user(:email => '')
    assert user.invalid?
    assert_not_equal 'is invalid', user.errors[:email]
    %w(invalid_email_format email@invalid invalid$character@mail.com other@not 123).each do |email|
      user.email = email
      assert user.invalid?, 'should be invalid with email ' << email
      assert user.errors[:email]
      assert_equal 1, user.errors[:email].to_a.size
      assert_equal 'is invalid', user.errors[:email]
    end
  end

  test 'should accept valid emails' do
    %w(a.b.c@example.com test_mail@gmail.com any@any.net email@test.br 123@mail.test).each do |email|
      user = new_user(:email => email)
      assert user.valid?, 'should be valid with email ' << email
      assert_nil user.errors[:email]
    end
  end

  test 'should require password to be set when creating a new record' do
    user = new_user(:password => '', :password_confirmation => '')
    assert user.invalid?
    assert user.errors[:password]
    assert_equal 'can\'t be blank', user.errors[:password]
  end

  test 'should require confirmation to be set when creating a new record' do
    user = new_user(:password => 'new_password', :password_confirmation => 'blabla')
    assert user.invalid?
    assert user.errors[:password]
    assert_equal 'doesn\'t match confirmation', user.errors[:password]
  end

  test 'should require password when updating/reseting password' do
    user = create_user
    user.password = ''
    user.password_confirmation = ''
    assert user.invalid?
    assert user.errors[:password]
    assert_equal 'can\'t be blank', user.errors[:password]
  end

  test 'should require confirmation when updating/reseting password' do
    user = create_user
    user.password_confirmation = 'another_password'
    assert user.invalid?
    assert user.errors[:password]
    assert_equal 'doesn\'t match confirmation', user.errors[:password]
  end

  test 'should require a password with minimum of 6 characters' do
    user = new_user(:password => '12345', :password_confirmation => '12345')
    assert user.invalid?
    assert user.errors[:password]
    assert_equal 'is too short (minimum is 6 characters)', user.errors[:password]
  end

  test 'should require a password with maximum of 20 characters long' do
    user = new_user(:password => 'x'*21, :password_confirmation => 'x'*21)
    assert user.invalid?
    assert user.errors[:password]
    assert_equal 'is too long (maximum is 20 characters)', user.errors[:password]
  end
end

