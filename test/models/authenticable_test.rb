require 'test_helper'
require 'digest/sha1'

class AuthenticableTest < ActiveSupport::TestCase

  test 'should respond to password and password confirmation' do
    user = new_user
    assert user.respond_to?(:password)
    assert user.respond_to?(:password_confirmation)
  end

  test 'should have email acessible' do
    assert field_accessible?(:email)
  end

  test 'should have password acessible' do
    assert field_accessible?(:password)
  end

  test 'should have password confirmation accessible' do
    assert field_accessible?(:password_confirmation)
  end

  test 'should not have password salt accessible' do
    assert_not field_accessible?(:password_salt)
  end

  test 'should not have encrypted password accessible' do
    assert_not field_accessible?(:encrypted_password)
  end

  test 'should not generate salt while setting password' do
    assert_nil new_user.password_salt
    assert_nil new_user(:password => nil).password_salt
    assert_nil new_user(:password => '').password_salt
  end

  test 'should generate password salt while saving' do
    assert_present create_user.password_salt
  end

  test 'should not change password salt when updating' do
    user = create_user
    salt = user.password_salt
    user.expects(:password_salt=).never
    user.save!
    assert_equal salt, user.password_salt
  end

  test 'should generate a sha1 hash for password salt' do
    now = Time.now
    Time.stubs(:now).returns(now)
    User.any_instance.stubs(:random_string).returns('random_string')
    user = create_user
    expected_salt = ::Digest::SHA1.hexdigest("--#{now.utc}--random_string--123456--")
    assert_equal expected_salt, user.password_salt
  end

  test 'should never generate the same salt for different users' do
    password_salts = []
    10.times do
      salt = create_user.password_salt
      assert_not password_salts.include?(salt)
      password_salts << salt
    end
  end

  test 'should not generate encrypted password while setting password' do
    assert_nil new_user.encrypted_password
    assert_nil new_user(:password => nil).encrypted_password
    assert_nil new_user(:password => '').encrypted_password
  end

  test 'should generate encrypted password while saving' do
    assert_present create_user.encrypted_password
  end

  test 'should encrypt password again if password has changed' do
    user = create_user
    encrypted_password = user.encrypted_password
    user.password = user.password_confirmation = 'new_password'
    user.save!
    assert_not_equal encrypted_password, user.encrypted_password
  end

  test 'should encrypt password using a sha1 hash' do
    Devise::Models::Authenticable.pepper = 'pepper'
    Devise::Models::Authenticable.stretches = 1
    user = create_user
    expected_password = ::Digest::SHA1.hexdigest("--#{user.password_salt}--pepper--123456--pepper--")
    assert_equal expected_password, user.encrypted_password
  end

  test 'should test for a valid password' do
    user = create_user
    assert user.valid_password?('123456')
    assert_not user.valid_password?('654321')
  end

  test 'should authenticate a valid user with email and password and return it' do
    user = create_user
    User.any_instance.stubs(:confirmed?).returns(true)
    authenticated_user = User.authenticate(user.email, user.password)
    assert_equal authenticated_user, user
  end

  test 'should return nil when authenticating an invalid user by email' do
    user = create_user
    authenticated_user = User.authenticate('another.email@email.com', user.password)
    assert_nil authenticated_user
  end

  test 'should return nil when authenticating an invalid user by password' do
    user = create_user
    authenticated_user = User.authenticate(user.email, 'another_password')
    assert_nil authenticated_user
  end
end
