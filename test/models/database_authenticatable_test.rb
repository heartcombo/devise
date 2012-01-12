require 'test_helper'
require 'digest/sha1'

class DatabaseAuthenticatableTest < ActiveSupport::TestCase
  test 'should downcase case insensitive keys when saving' do
    # case_insensitive_keys is set to :email by default.
    email = 'Foo@Bar.com'
    user = new_user(:email => email)

    assert_equal email, user.email
    user.save!
    assert_equal email.downcase, user.email
  end
  
  test 'should remove whitespace from strip whitespace keys when saving' do
    # strip_whitespace_keys is set to :email by default.
    email = ' foo@bar.com '
    user = new_user(:email => email)

    assert_equal email, user.email
    user.save!
    assert_equal email.strip, user.email
  end

  test "param filter should not convert booleans and integer to strings" do
    conditions = { 'login' => 'foo@bar.com', "bool1" => true, "bool2" => false, "fixnum" => 123, "will_be_converted" => (1..10) }
    conditions = Devise::ParamFilter.new([], []).filter(conditions)
    assert_equal( { 'login' => 'foo@bar.com', "bool1" => true, "bool2" => false, "fixnum" => 123, "will_be_converted" => "1..10" }, conditions)
  end

  test "param filter should not convert regular expressions to strings" do
    conditions = { "regexp" => /expression/ }
    conditions = Devise::ParamFilter.new([], []).filter(conditions)
    assert_equal( { "regexp" => /expression/ }, conditions)
  end

  test 'should respond to password and password confirmation' do
    user = new_user
    assert user.respond_to?(:password)
    assert user.respond_to?(:password_confirmation)
  end

  test 'should generate encrypted password while setting password' do
    user = new_user
    assert_present user.encrypted_password
  end

  test 'allow authenticatable_salt to work even with nil encrypted password' do
    user = User.new
    user.encrypted_password = nil
    assert_nil user.authenticatable_salt
  end

  test 'should not generate encrypted password if password is blank' do
    assert_blank new_user(:password => nil).encrypted_password
    assert_blank new_user(:password => '').encrypted_password
  end

  test 'should encrypt password again if password has changed' do
    user = create_user
    encrypted_password = user.encrypted_password
    user.password = user.password_confirmation = 'new_password'
    user.save!
    assert_not_equal encrypted_password, user.encrypted_password
  end

  test 'should test for a valid password' do
    user = create_user
    assert user.valid_password?('123456')
    assert_not user.valid_password?('654321')
  end

  test 'should not raise error with an empty password' do
    user = create_user
    user.encrypted_password = ''
    assert_nothing_raised { user.valid_password?('123456') }
  end

  test 'should be an invalid password if the user has an empty password' do
    user = create_user
    user.encrypted_password = ''
    assert_not user.valid_password?('654321')
  end

  test 'should respond to current password' do
    assert new_user.respond_to?(:current_password)
  end

  test 'should update password with valid current password' do
    user = create_user
    assert user.update_with_password(:current_password => '123456',
      :password => 'pass321', :password_confirmation => 'pass321')
    assert user.reload.valid_password?('pass321')
  end
  
  test 'should update password with valid current password and :as option' do
    user = create_user
    assert user.update_with_password(:current_password => '123456',
      :password => 'pass321', :password_confirmation => 'pass321', :as => :admin)
    assert user.reload.valid_password?('pass321')
  end
  
  test 'should add an error to current password when it is invalid' do
    user = create_user
    assert_not user.update_with_password(:current_password => 'other',
      :password => 'pass321', :password_confirmation => 'pass321')
    assert user.reload.valid_password?('123456')
    assert_match "is invalid", user.errors[:current_password].join
  end

  test 'should add an error to current password when it is blank' do
    user = create_user
    assert_not user.update_with_password(:password => 'pass321',
      :password_confirmation => 'pass321')
    assert user.reload.valid_password?('123456')
    assert_match "can't be blank", user.errors[:current_password].join
  end

  test 'should run validations even when current password is invalid or blank' do
    user = UserWithValidation.create!(valid_attributes)
    user.save
    assert user.persisted?
    assert_not user.update_with_password(:username => "")
    assert_match "usertest", user.reload.username
    assert_match "can't be blank", user.errors[:username].join
  end

  test 'should ignore password and its confirmation if they are blank' do
    user = create_user
    assert user.update_with_password(:current_password => '123456', :email => "new@example.com")
    assert_equal "new@example.com", user.email
  end

  test 'should not update password with invalid confirmation' do
    user = create_user
    assert_not user.update_with_password(:current_password => '123456',
      :password => 'pass321', :password_confirmation => 'other')
    assert user.reload.valid_password?('123456')
  end

  test 'should clean up password fields on failure' do
    user = create_user
    assert_not user.update_with_password(:current_password => '123456',
      :password => 'pass321', :password_confirmation => 'other')
    assert user.password.blank?
    assert user.password_confirmation.blank?
  end

  test 'should update the user without password' do
    user = create_user
    user.update_without_password(:email => 'new@example.com')
    assert_equal 'new@example.com', user.email
  end
  
  test 'should update the user without password with :as option' do
    user = create_user
    user.update_without_password(:email => 'new@example.com', :as => :admin)
    assert_equal 'new@example.com', user.email
  end

  test 'should not update password without password' do
    user = create_user
    user.update_without_password(:password => 'pass321', :password_confirmation => 'pass321')
    assert !user.reload.valid_password?('pass321')
    assert user.valid_password?('123456')
  end

  test 'downcase_keys with validation' do
    user = User.create(:email => "HEllO@example.com", :password => "123456")
    user = User.create(:email => "HEllO@example.com", :password => "123456")
    assert !user.valid?
  end
end
