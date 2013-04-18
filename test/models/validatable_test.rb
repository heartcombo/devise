# encoding: UTF-8
require 'test_helper'

class ValidatableTest < ActiveSupport::TestCase
  test 'should require email to be set' do
    user = new_user(:email => nil)
    assert user.invalid?
    assert user.errors[:email]
    assert_equal 'can\'t be blank', user.errors[:email].join
  end

  test 'should require uniqueness of email if email has changed, allowing blank' do
    existing_user = create_user

    user = new_user(:email => '')
    assert user.invalid?
    assert_no_match(/taken/, user.errors[:email].join)

    user.email = existing_user.email
    assert user.invalid?
    assert_match(/taken/, user.errors[:email].join)

    user.save(:validate => false)
    assert user.valid?
  end

  test 'should require correct email format if email has changed, allowing blank' do
    user = new_user(:email => '')
    assert user.invalid?
    assert_not_equal 'is invalid', user.errors[:email].join

    %w{invalid_email_format 123 $$$ () ☃ bla@bla.}.each do |email|
      user.email = email
      assert user.invalid?, 'should be invalid with email ' << email
      assert_equal 'is invalid', user.errors[:email].join
    end

    user.save(:validate => false)
    assert user.valid?
  end

  test 'should accept valid emails' do
    %w(a.b.c@example.com test_mail@gmail.com any@any.net email@test.br 123@mail.test 1☃3@mail.test).each do |email|
      user = new_user(:email => email)
      assert user.valid?, 'should be valid with email ' << email
      assert_blank user.errors[:email]
    end
  end

  test 'should require password to be set when creating a new record' do
    user = new_user(:password => '', :password_confirmation => '')
    assert user.invalid?
    assert_equal 'can\'t be blank', user.errors[:password].join
  end

  test 'should require confirmation to be set when creating a new record' do
    user = new_user(:password => 'new_password', :password_confirmation => 'blabla')
    assert user.invalid?
    assert_equal 'doesn\'t match confirmation', user.errors[:password].join
  end

  test 'should require password when updating/resetting password' do
    user = create_user

    user.password = ''
    user.password_confirmation = ''

    assert user.invalid?
    assert_equal 'can\'t be blank', user.errors[:password].join
  end

  test 'should require confirmation when updating/resetting password' do
    user = create_user
    user.password_confirmation = 'another_password'
    assert user.invalid?
    assert_equal 'doesn\'t match confirmation', user.errors[:password].join
  end

  test 'should require a password with minimum of 6 characters' do
    user = new_user(:password => '12345', :password_confirmation => '12345')
    assert user.invalid?
    assert_equal 'is too short (minimum is 6 characters)', user.errors[:password].join
  end

  test 'should require a password with maximum of 128 characters long' do
    user = new_user(:password => 'x'*129, :password_confirmation => 'x'*129)
    assert user.invalid?
    assert_equal 'is too long (maximum is 128 characters)', user.errors[:password].join
  end

  test 'should not require password length when it\'s not changed' do
    user = create_user.reload
    user.password = user.password_confirmation = nil
    assert user.valid?

    user.password_confirmation = 'confirmation'
    assert user.invalid?
    assert_not (user.errors[:password].join =~ /is too long/)
  end

  test 'should complain about length even if password is not required' do
    user = new_user(:password => 'x'*129, :password_confirmation => 'x'*129)
    user.stubs(:password_required?).returns(false)
    assert user.invalid?
    assert_equal 'is too long (maximum is 128 characters)', user.errors[:password].join
  end

  test 'should not be included in objects with invalid API' do
    assert_raise RuntimeError do
      Class.new.send :include, Devise::Models::Validatable
    end
  end

  test 'required_fields should be an empty array' do
    assert_equal Devise::Models::Validatable.required_fields(User), []
  end
end
