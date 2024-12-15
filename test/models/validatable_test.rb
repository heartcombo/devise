# encoding: UTF-8
# frozen_string_literal: true
require 'test_helper'

class ValidatableTest < ActiveSupport::TestCase
  test 'should require email to be set' do
    user = new_user(email: nil)
    assert user.invalid?
    assert user.errors[:email]
    assert user.errors.added?(:email, :blank)
  end

  test 'should require uniqueness of email if email has changed, allowing blank' do
    existing_user = create_user

    user = new_user(email: '')
    assert user.invalid?
    assert_no_match(/taken/, user.errors[:email].join)

    user.email = existing_user.email
    assert user.invalid?
    assert_match(/taken/, user.errors[:email].join)

    user.save(validate: false)
    assert user.valid?
  end

  test 'should require correct email format if email has changed, allowing blank' do
    user = new_user(email: '')
    assert user.invalid?
    assert_not_equal 'is invalid', user.errors[:email].join

    %w{invalid_email_format 123 $$$ () ☃}.each do |email|
      user.email = email
      assert user.invalid?, "should be invalid with email #{email}"
      assert_equal 'is invalid', user.errors[:email].join
    end

    user.save(validate: false)
    assert user.valid?
  end

  test 'should accept valid emails' do
    %w(a.b.c@example.com test_mail@gmail.com any@any.net email@test.br 123@mail.test 1☃3@mail.test).each do |email|
      user = new_user(email: email)
      assert user.valid?, "should be valid with email #{email}"
      assert_blank user.errors[:email]
    end
  end

  test 'should require password to be set when creating a new record' do
    user = new_user(password: '', password_confirmation: '')
    assert user.invalid?
    assert user.errors.added?(:password, :blank)
  end

  test 'should require confirmation to be set when creating a new record' do
    user = new_user(password: 'new_password', password_confirmation: 'blabla')
    assert user.invalid?

    assert user.errors.added?(:password_confirmation, :confirmation, attribute: "Password")
  end

  test 'should require password when updating/resetting password' do
    user = create_user

    user.password = ''
    user.password_confirmation = ''

    assert user.invalid?
    assert user.errors.added?(:password, :blank)
  end

  test 'should require confirmation when updating/resetting password' do
    user = create_user
    user.password_confirmation = 'another_password'
    assert user.invalid?

    assert user.errors.added?(:password_confirmation, :confirmation, attribute: "Password")
  end

  test 'should require a password with minimum of 7 characters' do
    user = new_user(password: '12345', password_confirmation: '12345')
    assert user.invalid?
    assert_equal 'is too short (minimum is 7 characters)', user.errors[:password].join
  end

  test 'should require a password with maximum of 72 characters long' do
    user = new_user(password: 'x'*73, password_confirmation: 'x'*73)
    assert user.invalid?
    assert_equal 'is too long (maximum is 72 characters)', user.errors[:password].join
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
    user = new_user(password: 'x'*73, password_confirmation: 'x'*73)
    user.stubs(:password_required?).returns(false)
    assert user.invalid?
    assert_equal 'is too long (maximum is 72 characters)', user.errors[:password].join
  end

  test 'should not be included in objects with invalid API' do
    exception = assert_raise RuntimeError do
      Class.new.send :include, Devise::Models::Validatable
    end

    expected_message = /Could not use :validatable module since .* does not respond to the following methods: validates_presence_of.*/
    assert_match expected_message, exception.message
  end

  test 'required_fields should be an empty array' do
    assert_equal [], Devise::Models::Validatable.required_fields(User)
  end

  
  test "password must require a lower case letter if require_lower is true" do
    with_password_requirement(:require_lower, false) do
      user = new_user(password: 'PASSWORD', password_confirmation: 'PASSWORD')
      assert user.valid?  
    end
    
    with_password_requirement(:require_lower, true) do
      user = new_user(password: 'PASSWORD', password_confirmation: 'PASSWORD')
      assert user.invalid?
      assert_equal 'must include at least one lowercase letter', user.errors[:password].join
    end
  end  

  test "password must require an upper case letter if require_upper is true" do
    with_password_requirement(:require_upper, false) do
      user = new_user(password: 'password', password_confirmation: 'password')
      assert user.valid?  
    end
    
    with_password_requirement(:require_upper, true) do
      user = new_user(password: 'password', password_confirmation: 'password')
      assert user.invalid?
      assert_equal 'must include at least one uppercase letter', user.errors[:password].join
    end
  end  

  test "password must require an upper case letter if require_digit is true" do
    with_password_requirement(:require_digit, false) do
      user = new_user(password: 'password', password_confirmation: 'password')
      assert user.valid?  
    end
    
    with_password_requirement(:require_digit, true) do
      user = new_user(password: 'password', password_confirmation: 'password')
      assert user.invalid?
      assert_equal 'must include at least one number', user.errors[:password].join
    end
  end 

  test "password must require special character if require_special is true" do
    with_password_requirement(:require_special, false) do
      user = new_user(password: 'password', password_confirmation: 'password')
      assert user.valid?  
    end
    
    with_password_requirement(:require_special, true) do
      user = new_user(password: 'password', password_confirmation: 'password')
      assert user.invalid?
      assert_equal 'must include at least one special character', user.errors[:password].join
    end
  end 


  test "special character must be within defined special character set if it is custom" do
    with_password_requirement(:require_special, true) do
      with_password_requirement(:special_characters, '!') do
        user = new_user(password: 'password!', password_confirmation: 'password!')
        assert user.valid?  

        user = new_user(password: 'password?', password_confirmation: 'password?')
        assert user.invalid?  
        assert_equal 'must include at least one special character', user.errors[:password].join
      end
    end
  end 

  def with_password_requirement(requirement, value)
    # Change the password requirement and restore it after the block is executed
    original_password_complexity= User.public_send("password_complexity")

    updated_password_complexity = original_password_complexity.dup
    updated_password_complexity[requirement] = value

    User.public_send("password_complexity=", updated_password_complexity)
    yield
  ensure
    User.public_send("password_complexity=", original_password_complexity)
  end
end
