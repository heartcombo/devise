require 'test_helper'
require 'digest/sha1'

class AuthenticableTest < ActiveSupport::TestCase

  def valid_attributes(attributes={})
    { :email => 'test@email.com',
      :password => '12345',
      :password_confirmation => '12345' }.update(attributes)
  end

  def new_user(attributes={})
    User.new(valid_attributes(attributes))
  end

  def create_user(attributes={})
    User.create!(valid_attributes(attributes))
  end

  def field_accessible?(field)
    new_user(field => 'test').send(field) == 'test'
  end

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
    assert field_accessible?(:password)
  end

  test 'should not have password salt accessible' do
    assert_not field_accessible?(:password_salt)
  end

  test 'should not have encrypted password accessible' do
    assert_not field_accessible?(:encrypted_password)
  end

  test 'should generate password salt after set the password' do
    assert_present new_user.password_salt
    assert_present create_user.password_salt
  end

  test 'should not generate salt while setting password to nil or blank string' do
    assert_nil new_user(:password => nil).password_salt
    assert_nil new_user(:password => '').password_salt
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
    expected_salt = ::Digest::SHA1.hexdigest("--#{now.utc}--#{12345}--")
    user = create_user
    assert_equal expected_salt, user.password_salt
  end

  test 'should generate encrypted password after setting a password' do
    assert_present new_user.encrypted_password
    assert_present create_user.encrypted_password
  end

  test 'should not generate encrypted password while setting password to nil or blank string' do
    assert_nil new_user(:password => nil).encrypted_password
    assert_nil new_user(:password => '').encrypted_password
  end

  test 'should not encrypt password if it didn\'t change' do
    user = create_user
    encrypted_password = user.encrypted_password
    user.expects(:encrypted_password=).never
    user.password = '12345'
    assert_equal encrypted_password, user.encrypted_password
  end

  test 'should encrypt password again if password has changed' do
    user = create_user
    encrypted_password = user.encrypted_password
    user.password = 'new_password'
    assert_not_equal encrypted_password, user.encrypted_password
  end

  test 'should encrypt password using a sha1 hash' do
    digest_key = Devise::Authenticable::SECURE_AUTH_SITE_KEY = 'digest_key'
    user = create_user
    expected_password = ::Digest::SHA1.hexdigest("--#{user.password_salt}--#{digest_key}--#{12345}--")
    assert_equal expected_password, user.encrypted_password
  end
end

